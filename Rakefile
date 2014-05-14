require "bundler/gem_tasks"

task :default => :test

desc "Run the tests"
task :test do
  Dir.glob(File.expand_path("../test/*.rb", __FILE__)).each do |file|
    require file
  end
end
