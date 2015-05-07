# Stapler::Commandline

require 'mixlib/cli'

module Stapler
  # Stapler::Commandline
  class Commandline
    include Mixlib::CLI

    option :help,        short:        '-h',
                         long:         '--help',
                         description:  'Show this message',
                         on:           :tail,
                         boolean:      true,
                         show_options: true,
                         exit:         0

    option :project,     short:       '-p PROJECT',
                         long:        '--project PROJECT',
                         description: 'The project tag',
                         default:     'GRPTECH_OnlineHosting'

    option :application, short:       '-a APPLICATION',
                         long:        '--application APPLICATION',
                         description: 'The application tag',
                         default:     'Unknown'

    option :uuid,        short:       '-u UUID',
                         long:        '--uuid UUID',
                         description: 'The UUID tag'

    option :device,      short:       '-d DEVICE',
                         long:        '--device DEVICE',
                         description: 'The device tag'

    option :size,        short:       '-s SIZE',
                         long:        '--size SIZE',
                         description: 'The volume size',
                         default:     100

    option :type,        short:       '-t TYPE',
                         long:        '--type TYPE',
                         description: 'The volume type',
                         default:     'standard'

    def run
      parse
    end

    private

    def parse
      stapler = Stapler::Base.new

      cli = Stapler::Commandline.new
      cli.parse_options

      case (action = action cli.cli_arguments)
      when 'version'
        stapler.version
      when 'attach'
        stapler.attach(cli.config, Stapler::Configuration.new.metadata) if validate(action, cli.config)
      when 'snapshot'
        puts 'snapshot'
      else
        puts cli.banner
      end

    rescue ArgumentError => e
      puts e.message
      puts cli.banner
    end

    def action(array)
      array.select { |i| %w(version attach snapshot).include? i }.first
    end

    def validate(action, config)
      fail ArgumentError, 'Missing arguments' unless send(action, config)
      true
    end

    def attach(config)
      config[:project] && config[:application] && config[:uuid] && config[:device]
    end

    def snapshot(config)
      config[:project] && config[:application] && config[:uuid]
    end
  end
end
