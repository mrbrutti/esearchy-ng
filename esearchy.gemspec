SPEC = Gem::Specification.new do |s| 
  s.name = "esearchy"
  s.version = "0.2.0.7"
  s.author = "Matias P. Brutti"
  s.email = "matiasbrutti@gmail.com"
  s.homepage = "http://freedomcoder.com.ar/esearchy"
  s.platform = Gem::Platform::RUBY
  s.summary = "A library to search for emails in search engines"
  s.files = Dir["lib/**/*.*"] + Dir["bin/**/*.*"]
  %w{esearchy}.each do |command_line_utility|
    s.executables << command_line_utility
  end
  s.require_path = "lib"
  s.has_rdoc = true 
  s.extra_rdoc_files = ["README.rdoc"] 
  s.add_dependency("pdf-reader", ">= 0.7.5")
  s.add_dependency("json", ">= 1.1.9")
  s.add_dependency("FreedomCoder-rubyzip", ">= 0.9.3") # This is for Ruby-1.9 compatibility
  #s.add_dependency("ruby-ldap", ">= 0.9.9") # Need to check other OSes and Ruby-1.9
  s.add_dependency("spidr", ">= 0.2.1") # Need to check other OSes and Ruby-1.9
end
