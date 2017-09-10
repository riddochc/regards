Gem::Specification.new do |s|
  s.name        = "regards"
  s.version     = "0.0.1"
  s.licenses    = ["LGPL-3.0"]
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Regards are like facets - a collection of utility functions, to refine with."
  s.description = "Regards is a library of utility functions, in the style of the facets gem. Being implemented as refinements, these can modify core ruby classes for the duration of the file they&#8217;re used in, without causing conflicts in other code. Become more refined by having regards, not concerns."
  s.authors     = ["Chris Riddoch"]
  s.email       = "riddochc@gmail.com"
  s.date        = "2017-09-10"
  s.files       = ["Gemfile",
                   "LICENSE",
                   "README.adoc",
                   "Rakefile",
                   "console",
                   "lib/regards/regexp/unroll.rb",
                   "lib/regards/regexp.rb",
                   "lib/regards/string/rewrite.rb",
                   "lib/regards/string/to_numeric.rb",
                   "lib/regards/string/unhexdump.rb",
                   "lib/regards/string.rb",
                   "lib/regards/version.rb",
                   "lib/regards.rb",
                   "project.yaml",
                   "regards.gemspec",
                   "t/regexp.rb",
                   "t/string.rb"]
  s.homepage    = "https://github.com/riddochc/regards"


  s.add_development_dependency "rake", "= 12.0.0"
  s.add_development_dependency "asciidoctor", "= 1.5.6.1"
  s.add_development_dependency "pry", "= 0.10.1"
  s.add_development_dependency "rugged", "= 0.26.0"
  s.add_development_dependency "minitest", "= 5.10.3"
end
