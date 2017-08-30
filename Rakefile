# coding: utf-8
# frozen-string-literal: true
# vim: syntax=ruby
#
# © Chris Riddoch, 2017
# This software is licensed under the GPLv3 and comes with ABSOLUTELY NO WARRANTY; for details see LICENSE in the project's main directory.

require "yaml"
require "find"
require "erb"
require "set"
require "open3"

begin
  require "asciidoctor"
  require "rugged"
rescue LoadError => e
  puts "You're missing the #{e.message[/\S+$/]} gem, you need it to run this Rakefile"
  exit -1
end

def installed_gem_versions
  rx = /^(?<name>\S+)\s\((?<versions>[^)]+)/
  gems = {}
  IO.popen(%w(gem list -l)).readlines
    .map {|line| m = rx.match(line) }
    .compact
    .map {|m| gems[m['name']] = m['versions'].split(', ')
                                  .map {|v| begin
                                              Gem::Version.new(v)
                                            rescue ArgumentError
                                              nil
                                            end
                                  }.compact.max_by(&:itself)
         }
  gems
end

def filtered_project_files()
  exceptions = %w{./tags ./cscope.out ./.starscope.db}.to_set
  Dir.chdir __dir__ do
    Find.find(".").reject {|f|
      !File.file?(f) ||
       f =~ %r{^\./(.git|tmp|search)} ||
       f =~ %r{\.(so|gem)$} ||
       exceptions.include?(f)
    }.map {|f| f.sub %r{^\./}, '' }
  end
end

def repo_clean?(r)
  retval = true
  r.status {|f, status|
    unless status.include?(:ignored)
      retval = false ; break
    end
  }
  retval
end

project_dir = __dir__
adoc = Asciidoctor.load_file(File.join(project_dir, "README.adoc"))
summary = adoc.sections.find {|s| s.name == "Description" }.blocks[0].content.gsub(/\n/, ' ')
description = adoc.sections.find {|s| s.name == "Description" }.blocks[1].content.gsub(/\n/, ' ')
config = YAML.load_file(File.join(project_dir, "project.yaml"))
project = adoc.doctitle # config.fetch('name', File.split(File.expand_path(__dir__)).last)
project_class = project.split(/[^A-Za-z0-9]/).map(&:capitalize).join
version = adoc.attributes['revnumber']
dependencies = config.fetch('dependencies', {})
dev_dependencies = config.fetch('dev_dependencies', {})
license = config.fetch('license') { "LGPL-3.0" }

gemspec_template = <<GEMSPEC
Gem::Specification.new do |s|
  s.name        = "<%= project %>"
  s.version     = "<%= version %>"
  s.licenses    = ["<%= license %>"]
  s.platform    = Gem::Platform::RUBY
  s.summary     = "<%= summary %>"
  s.description = "<%= description %>"
  s.authors     = ["<%= adoc.author %>"]
  s.email       = "<%= adoc.attributes['email'] %>"
  s.date        = "<%= Date.today %>"
  s.files       = [<%= filtered_project_files().map{|f| '"' + f + '"' }.join(",\n                   ") %>]
  s.homepage    = "<%= adoc.attributes['homepage'] %>"

% dependencies.each_pair do |req, vers|
  s.add_dependency "<%= req %>", "<%= vers %>"
% end

% dev_dependencies.each do |req, vers|
  s.add_development_dependency "<%= req %>", "<%= vers %>"
% end
end
GEMSPEC

task default: [:clean, :versionfile, :gemspec, :gemfile, :build]

desc "Test for uncommitted changes"
task :git_check do
  repo = Rugged::Repository.new(".")
  unless repo_clean?(repo)
    puts "Warning: repository contains uncommitted changes!"
  end
end

desc "Generate lib/#{project}/version.rb"
task :versionfile do
  File.open(File.join("lib", project, "version.rb"), 'w') {|f|
    File.open(__FILE__, 'r').each_line.take_while {|line| line =~ /^\s*#/ }.each {|line| f.print line }
    f.puts "\nmodule #{project_class}\n  module Version"
    major, minor, tiny = *version.split(/\./).map {|p| p.to_i }
    f.puts "    String = \"" + version + '"'
    f.puts "    Major = #{major}"
    f.puts "    Minor = #{minor}" unless minor.nil?
    f.puts "    Tiny = #{tiny}" unless tiny.nil?
    f.puts "  end\nend"
  }
end

desc "Generate #{project}.gemspec"
task :gemspec => [:git_check, :versionfile] do
  requires = filtered_project_files()
    .select {|f| File.extname(f) != ".db" } # exclude binary files.
    .map {|f| File.readlines(f).grep (/^\s*require(?!_relative)\b/) }
    .flatten
    .map {|line| line.split(/['"]/).at(1) }
    .compact
    .uniq
    .grep_v(/<%=|%>|#|\$/)
  requires.delete(project)

  builtin_requireables = IO.popen("ruby-builtin-requireables").readlines.map(&:chomp)

  available_gems = installed_gem_versions()
  gem_names = available_gems.keys.to_set
  basic_requirements = {}
  ["rake", "asciidoctor", "pry", "rugged"].each {|g|
    basic_requirements[g] = "= #{available_gems[g]}"
  }

  req_names = basic_requirements.keys.to_set
  if !gem_names.superset?(req_names)
    puts "Missing dev dependencies: " + (req_names - gem_names).to_a.join(', ')
  else
    dev_dependencies = basic_requirements.merge(dev_dependencies)
  end

  # Catch cases like 'require "some_gem/subpart"'
  preslash_subgems = Regexp.new("^" + Regexp.union(dev_dependencies.keys + dependencies.keys).to_s + "/")
  subgem_dependencies = requires.grep(preslash_subgems)

  missing_deps = (requires - builtin_requireables - dependencies.keys - dev_dependencies.keys - subgem_dependencies)
  if missing_deps.length > 0
    puts "There may be some dependencies not listed in project.yml:"
    puts missing_deps.join(", ")
  end

  File.open(project + ".gemspec", 'w') do |f|
    erb = ERB.new(gemspec_template, nil, "%<>")
    f.write(erb.result(binding))
  end
end

desc "Generate Gemfile"
task :gemfile do
  unless File.exists?("Gemfile")
    File.open("Gemfile", 'w') do |f|
      f.puts "source 'https://rubygems.org'"
      f.puts "gemspec"
      f.puts
    end
  end
end

desc "Create #{project}-#{version}.gem"
task :build => [:git_check, :gemspec] do
  system "gem build #{project}.gemspec"
end

desc "Installs this project as a rubygem"
task :install => [:git_check, :build] do
  system "gem install ./#{project}-#{version}.gem"
end

desc "Generate README.html"
task :readme do
  sh "asciidoctor", "README.adoc"
end

run_spec = proc do |file|
  lib_dir = File.join(File.dirname(File.expand_path(__FILE__)), 'lib')
  rubylib = ENV['RUBYLIB']
  ENV['RUBYLIB'] ? (ENV['RUBYLIB'] += ":#{lib_dir}") : (ENV['RUBYLIB'] = lib_dir)
  sh RbConfig.ruby, file
  ENV['RUBYLIB'] = rubylib
end

spec_task = proc do |description, name, file, coverage|
  desc description
  task name do
    run_spec.call(file)
  end

  desc "#{description} with warnings, some warnings filtered"
  task :"#{name}_w" do
    rubyopt = ENV['RUBYOPT']
    ENV['RUBYOPT'] = "#{rubyopt} -w"
    ENV['WARNING'] = '1'
    run_spec.call(file)
    ENV.delete('WARNING')
    ENV['RUBYOPT'] = rubyopt
  end

  if coverage
    desc "#{description} with coverage"
    task :"#{name}_cov" do
      ENV['COVERAGE'] = '1'
      run_spec.call(file)
      ENV.delete('COVERAGE')
    end
  end
end

task :spec => [:spec_string]
task :test => [:spec]

spec_task.call("Test string methods", :spec_string, "t/string.rb")


desc "Check syntax of all ruby files"
task :check_syntax do
  ok = []
  bad = {}
  (["Gemfile", "Rakefile", "#{project}.gemspec"] + Dir['**/*.rb']).each do |f|
    o, s = Open3.capture2e(RbConfig.ruby, "-c", f)
    if s.success?
      ok.push(f)
    else
      bad[f] = o
    end
  end
  if bad.any?
    puts "Syntax errors detected:"
    bad.values.each {|s| puts s }
    exit 72  # closest thing to a standard 'syntax error' code
  end
end

desc "Generate tags file and starscope index"
task :starscope => [:search_clean] do
  Dir.chdir(project_dir) do
    tf = File.open("cscope.files", 'w')
    filtered_project_files().grep(%r{^(bin|lib)/.*\.rb$})
      .each {|f| tf.puts(f) }
    tf.close
    sh "starscope", "-e", "cscope"
    sh "ctags", "--fields=+i", "-n", "-L", tf.path
    rm tf.path
  end
end

desc "Generate codequery database"
task :codequery => [:starscope] do
  cd(project_dir) do
    cmd = ["cqmakedb", "-s", "#{project}-codequery.db"]
    cmd += %w[-c cscope.out -t tags -p]
    sh *cmd
  end
end

task :search_clean do
  cd(project_dir) do
    rm_rf "starscope"
    rm_f ".starscope.db"
    rm_f "#{project}-codequery.db"
    rm_f "cscope.out"
    rm_f "tags"
  end
end

task :clean => [:search_clean] do
  cd(project_dir) do
    rm_f "#{project}-#{version}.gem"
    rm_f "lib/#{project}/version.rb"
    rm_f "#{project}.gemspec"
    rm_f "README.html"
    rm_rf "doc"
    rm_rf ".yardoc"
  end
end

