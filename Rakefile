require "bundler/gem_tasks"

require 'rubygems/package'
require 'gemfury'
require 'gemfury/command'

namespace 'fury' do
  desc "Build gem and push it to Gemfury"
  task :release, [:gemspec, :as] do |t, args|
    gemspec = args[:gemspec] ||
              FileList["#{Dir.pwd}/*.gemspec"][0]

    as = args[:as] || 'fairfax'

    if gemspec.nil? || !File.exist?(gemspec)
      puts "No gemspec found"
    else
      puts "Building #{File.basename(gemspec)}"
      spec = Gem::Specification.load(gemspec)

      if Gem::Package.respond_to?(:build)
        Gem::Package.build(spec)
      else
        require 'rubygems/builder'
        Gem::Builder.new(spec).build
      end

      gemfile = File.basename(spec.cache_file)

      params = ['push', gemfile]
      params << "--as=#{args[:as]}" if as

      Gemfury::Command::App.start(params)
    end
  end
end

namespace 'gemfury' do
  task :release => 'fury:release'
end
