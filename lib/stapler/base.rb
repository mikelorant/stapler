module Stapler
  # Stapler::Base
  class Base
    def version
      puts Stapler::VERSION
    end

    def attach(config, metadata)
      ec2 = Stapler::Ec2.new(metadata[:region])

      project, application, uuid = config[:project], config[:application], config[:uuid]
      device = config[:device]
      size, type = config[:size], config[:type]

      availability_zone = metadata[:availabilityZone]
      instance_id = metadata[:instanceId]

      name = ec2.get_instance_name_by_instance_id(instance_id)
      volume_name = format('%s-%s', name, device)

      puts 'Finding volume...'
      if (snapshot_id = ec2.get_latest_snapshot_id_by_uuid(uuid))
        puts "Snapshot found: #{snapshot_id}"
      else
        puts "No snapshot found. An empty #{type} volume will be created of #{size} GB."
      end

      puts 'Creating volume...'
      if (volume_id = ec2.create_volume(size, type, availability_zone, snapshot_id))
        puts "Volume created: #{volume_id}"

        puts 'Tagging volume...'
        if ec2.tag_volume(volume_id, volume_name, project, application, uuid)
          puts 'Volume tagged.'
        else
          puts 'Volume failed tagging.'
        end

        puts 'Attaching volume...'
        if ec2.attach_volume(volume_id, instance_id, device)
          puts 'Volume attached to instance.'
        else
          puts 'Volume attachment failed.'
          exit 1
        end
      else
        puts 'Volume failed creation.'
        exit 1
      end
    end
  end
end
