require './lib/resque/plugins/mission/version'

Gem::Specification.new do |s|
  s.name        = "resque-mission"
  s.authors     = ["Matthew Lyon", "Troy Howard"]
  s.email       = "thoward37@gmail.com"
  s.license     = 'Apache 2.0'
  s.homepage    = "http://github.com/thoward/resque-mission"
  s.summary     = "resque-mission adds Missions (multi-step jobs) to Resque"
  s.description = ""

  s.version     = Resque::Plugins::Mission::Version
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.has_rdoc    = false
  s.files       = %w( README.md LICENSE )
  s.files      += Dir.glob('lib/**/*')
  s.require_paths = ["lib"]

  s.rubygems_version = "1.8.23"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<resque>, ["~> 1.19"])
      s.add_runtime_dependency(%q<resque-status>, ["~> 0.4.1"])
    else
      s.add_runtime_dependency(%q<resque>, ["~> 1.19"])
      s.add_runtime_dependency(%q<resque-status>, ["~> 0.4.1"])
    end
  else
    s.add_runtime_dependency(%q<resque>, ["~> 1.19"])
    s.add_runtime_dependency(%q<resque-status>, ["~> 0.4.1"])
  end
end
