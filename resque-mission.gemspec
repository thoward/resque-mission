Gem::Specification.new do |s|
  s.name        = "resque-mission"
  s.version     = '0.1.0'
  s.authors     = ["Troy Howard"]
  s.email       = "thoward37@gmail.com"
  s.homepage    = "http://github.com/thoward/resque-mission"
  s.summary     = "resque-mission adds Missions (multi-step jobs) to Resque"
  s.description = ""
  s.required_rubygems_version = ">= 1.3.6"
  s.files = ["lib/resque-mission.rb", "lib/resque/plugins/mission.rb"]
  s.add_dependency 'resque'
  s.add_dependency 'resque-status'
  # s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.license = 'Apache 2.0'
end
