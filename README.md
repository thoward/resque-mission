resque-mission
==============

resque-mission adds Missions (multi-step jobs) to Resque.

## Example

```ruby
require 'resque-mission'

class TestMission < Resque::Plugins::Mission

  # specify the queue (string/symbol)
  queue :test

  attr_reader :a, :b, :c

  # called by create_from_options
  def initialize(a, b, c)
    @a = a
    @b = b
    @c = c
  end

  # implement this to rehydrate state from queue
  # can modify what's passed to queue!(...) to whatever initialize wants
  # eg: fetch an object from db by id, and pass obj to initialize 
  def self.create_from_options(args={})
    new(args['a'], args['b'], args['c'])
  end

  # steps are executed in the order they are declared here
  # each one maps to a method of the same name
  step :step1
  step :step2

  def step1
    sleep 2
    `echo '#{a} #{b} #{c}' > /tmp/step1.$(date -d "today" +"%Y%m%d%H%M%S").log`
  end

  def step2
    sleep 5
    `echo '#{a} #{b} #{c}' > /tmp/step2.$(date -d "today" +"%Y%m%d%H%M%S").log`
  end

end

# enqueue
TestMission.queue!({
  :a => "Mission", 
  :b => "Impossible",
  :c => "Accomplished"
})
```

## Requirements/Dependencies

* [resque](http://github.com/defunkt/resque/) (1.8ish)
* [resque-status](http://github.com/quirkey/resque-status/) (0.4ish)

## Contributions

Original implementation (and clever name) by [Matthew Lyon](http://github.com/mattly).
Wrapping it up and delivering it as a plugin/gem (and maintaining it from here on out) by [Troy Howard](http://github.com/thoward)

## Copyright

Copyright © 2013 Troy Howard. See LICENSE for details.