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

    desc 'attach', 'Attaches the latest snapshot based on a tag to an instance.'

    method_option :project,     type: :string,  aliases: '-p', required: true,       desc: 'The project tag.'
    method_option :service,     type: :string,  aliases: '-s', required: true,       desc: 'The service tag.'
    method_option :environment, type: :string,  aliases: '-e', required: true,       desc: 'The environment tag.'
    method_option :uuid,        type: :string,  aliases: '-u', required: true,       desc: 'The UUID tag.'
    method_option :creator,     type: :string,  aliases: '-c', default:  'Stapler',  desc: 'The creator tag.'
    method_option :expires,     type: :string,  aliases: '-x', default:  'Never',    desc: 'The expiry tag.'
    method_option :management,  type: :string,  aliases: '-m', default:  'OH',       desc: 'The management tag.'
    method_option :device,      type: :string,  aliases: '-d', default:  '/dev/sdf', desc: 'The device to use.'
    method_option :size,        type: :numeric, aliases: '-z', default:  10,         desc: 'The volume size.'
    method_option :type,        type: :string,  aliases: '-t', default:  'standard', desc: 'The volume type.'
    method_option :interval,    type: :string,  aliases: '-i', default:  'daily',    desc: 'The snapshot interval.'
    method_option :preserve,    type: :string,  aliases: '-r', default:  'true',     desc: 'Preserve the volume from deletion.'

    def attach
      Stapler::Base.new.attach(options, Stapler::Configuration.new.metadata)
    end

    desc 'snapshot', 'Snapshots the volume attached to an instance.'

    def snapshot
      Stapler::Base.new.snapshot(options, Stapler::Configuration.new.metadata)
    end

    desc 'tag', 'Tags the volume attached to an instance.'

    method_option :project,     type: :string,  aliases: '-p', required: true,       desc: 'The project tag.'
    method_option :service,     type: :string,  aliases: '-s', required: true,       desc: 'The service tag.'
    method_option :environment, type: :string,  aliases: '-e', required: true,       desc: 'The environment tag.'
    method_option :creator,     type: :string,  aliases: '-c', default:  'Stapler',  desc: 'The creator tag.'
    method_option :expires,     type: :string,  aliases: '-x', default:  'Never',    desc: 'The expiry tag.'
    method_option :management,  type: :string,  aliases: '-m', default:  'OH',       desc: 'The management tag.'
    method_option :interval,    type: :string,  aliases: '-i', default:  'daily',    desc: 'The snapshot interval.'
    method_option :preserve,    type: :string,  aliases: '-r', default:  'true',     desc: 'Preserve the volume from deletion.'

    def tag
      Stapler::Base.new.tag(options, Stapler::Configuration.new.metadata)
    end
  end
end
