require 'resque'
require 'resque-status'

module Resque
  module Plugins
    class Mission

      attr_reader :progress

      # When subclassing Task, we also want to make it available as a resque job
      def self.inherited(subklass)
        subklass.const_set('Job', Class.new(Mission::Job))
        subklass::Job.const_set('TASK_CLASS', subklass)
      end

      # Internal: The list of steps to be run on #call
      def self.steps
        @steps ||= []
      end

      # Public: Override this in your class to allow new tasks to be created from
      # the queue. The given args will be what is fed to .queue
      #
      # args - from self.queue!
      def self.create_from_options(args={})
        new args
      end

      # Public: Create a Queue Job.
      #
      # args - Hash that will be fed to self.create_from_options from the queue.
      def self.queue!(args={})
        self::Job.create({'args' => args})
      end

      # Public: Sets the queue name for resque
      def self.queue(q=nil)
        if q then @queue = q.to_s
        else @queue ||= "statused"
        end
      end

      # Public: Declare a step to be run on #call. Steps will be run in the order
      # they are declared.
      #
      # method_name - a symbol name for the method to be called.
      # options - An optional Hash of information about the step.
      #     current arguments:
      #     - :message => Used for status updates, vs. method_name titlecased
      def self.step(method_name, options={})
        steps << [method_name, options]
      end

      # Public: Perform the Mission
      #
      # status - Optional Mission::Progress object
      # block - if given, will yield idx, total, status message to the block
      #         before performing the step
      def call(status=nil, &block)
        @progress = status || Progress.new
        start_timer
        self.class.steps.each_with_index do |step, index|
          method_name, options = step
          next if progress.completed?(method_name.to_s)
          progress.start method_name.to_s
          name = options[:message] || (method_name.to_s.gsub(/\w+/) {|word| word.capitalize})
          yield index, self.class.steps.length, name if block_given?
          send method_name
        end
        progress.finish
      rescue Object => e
        progress.failures += 1
        raise e
      end

      private
      # Private: start the timer
      def start_timer
        @start_time = Time.now.to_f
      end

      # Private: time since #call was called and now
      def delta_time
        return 0 unless @start_time
        Time.now.to_f - @start_time
      end

      # Private: Key for Statsd
      def stats_key(key=nil)
        @key_base ||= self.class.name.downcase.gsub(/\s+/,"_").gsub('::','.')
        key ? "#{@key_base}.#{key}" : @key_base
      end

      public

      class Job < Resque::JobWithStatus
        # Internal: used by Resque::JobWithStatus to get the queue name
        def self.queue
          self::TASK_CLASS.queue
        end

        # Internal: called by Resque::JobWithStatus to perform the job
        def perform
          task = self.class::TASK_CLASS.create_from_options(@options['args'])
          @options['progress'] = Progress[@options['progress'] || {}]
          task.call(@options['progress']) {|idx,total,msg| at idx, total, msg }
          completed
        end

        # Internal: used by Resque::JobWithStatus to handle failure
        # Stores the progress object on the exception so we can pass it through
        # to the resque callback and store it in the failure.
        def on_failure(e)
          e.instance_variable_set :@job_progress, @options['progress']
          raise e
        end

        # Internal: resque on failure callback, sorted
        # Takes our progress object and injects it back into the arguments hash
        # so that when the job is retried it knows where to resume.
        def self.on_failure_1111_store_progress(e, *args)
          args.last['progress'] = e.instance_variable_get :@job_progress
        end
      end

      class Progress < Hash
        def failures
          self['failures'] ||= 0
        end

        def failures=(int)
          self['failures'] = int
        end

        def start(step)
          completed.push delete('working') if working
          self['working'] = step
        end

        def working
          self['working']
        end

        def completed
          self['completed'] ||= []
        end

        def completed?(step)
          completed.include?(step)
        end

        def finish
          completed.push delete('working') if self['working']
          self['finished'] = true
        end

        def finished?
          self['finished'].present?
        end
      end
    end
  end
end