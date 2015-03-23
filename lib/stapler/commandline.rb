# Stapler::Commandline

require 'mixlib/cli'

module Stapler
  # Stapler::Commandline
  class Commandline
    include Mixlib::CLI

    option :help,
           short:        '-h',
           long:         '--help',
           description:  'Show this message',
           on:           :tail,
           boolean:      true,
           show_options: true,
           exit:         0

    option :project,
           short:       '-p PROJECT',
           long:        '--project PROJECT',
           description: 'The project tag',
           default:     'GRPTECH_OnlineHosting'

    option :application,
           short:       '-a APPLICATION',
           long:        '--application APPLICATION',
           description: 'The application tag',
           default:     'Unknown'

    option :uuid,
           short:       '-u UUID',
           long:        '--uuid UUID',
           description: 'The UUID tag'

    option :device,
           short:       '-d DEVICE',
           long:        '--device DEVICE',
           description: 'The device tag'

    option :size,
           short:       '-s SIZE',
           long:        '--size SIZE',
           description: 'The volume size',
           default:     100

    option :type,
           short:       '-t TYPE',
           long:        '--type TYPE',
           description: 'The volume type',
           default:     'standard'

    option :version,
           short:       '-v',
           long:        '--version',
           description: 'Show the version',
           on:          :tail,
           boolean:     true

    def run
      parse
    end

    private

    def parse
      cli = Stapler::Commandline.new
      cli.parse_options

      stapler = Stapler::Base.new

      if cli.config[:version]
        stapler.version
      elsif attach(cli.config)
        stapler.attach(cli.config, Stapler::Configuration.new.metadata)
      else
        puts cli.banner
      end
    end

    def attach(config)
      config[:application] && config[:uuid] && config[:device]
    end
  end
end
