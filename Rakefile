require 'rubygems'
require 'spec/rake/spectask'

task :default => 'spec'

desc "Run all specs."
Spec::Rake::SpecTask.new("spec") do |t|
  t.spec_files = FileList["specs/**/*_spec.rb"]
end

namespace :spec do
  
  desc "Run all specs for lib."
  Spec::Rake::SpecTask.new("lib") do |t|
    t.spec_files = FileList["specs/lib/*_spec.rb"]
  end

  desc "Run coverage report."
  Spec::Rake::SpecTask.new("rcov") do |t|
    t.spec_files = FileList["specs/**/*_spec.rb"]
    t.rcov = true
    t.rcov_dir = "specs/coverage"
    t.rcov_opts = ['--exclude', "specs,/Library/Ruby/Gems/1.8/gems"] 
  end

end
