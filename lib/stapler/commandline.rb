# Stapler::Commandline

require 'thor'

module Stapler
  # Stapler::Commandline
  class Commandline < Thor
    package_name 'Stapler'
    map ['-v', '--version'] => :version

    desc 'version', 'Print the version and exit.'

    def version
      Stapler::Base.new.version
    end

    desc 'attach', 'Refresh stopped instances in all load balancers.'

    method_option :project,
                  type:     :string,
                  aliases:  '-p',
                  required: true,
                  desc:     'The project tag.'

    method_option :application,
                  type:     :string,
                  aliases:  '-a',
                  required: true,
                  desc:     'The application tag.'

    method_option :uuid,
                  type:     :string,
                  aliases:  '-u',
                  required: true,
                  desc:     'The UUID tag.'

    method_option :device,
                  type:     :string,
                  aliases:  '-d',
                  default:  '/dev/sdf',
                  desc:     'The device to use.'

    method_option :size,
                  type:     :numeric,
                  aliases:  '-s',
                  default:  10,
                  desc:     'The volume size.'

    method_option :type,
                  type:     :string,
                  aliases:  '-t',
                  default:  'standard',
                  desc:     'The volume type.'

    def attach
      Stapler::Base.new.attach(options, Stapler::Configuration.new.metadata)
    end
  end
end
