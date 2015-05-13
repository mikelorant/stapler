module Stapler
  # Stapler::Base
  class Base
    def version
      puts Stapler::VERSION
    end

    def attach(options, metadata)
      ec2 = Stapler::Ec2.new(metadata[:region])

      name = ec2.get_instance_name_by_instance_id(metadata[:instanceId])
      volume_name = format('%s-%s', name, options[:device])

      puts 'Finding volume...'
      if (volume_id = ec2.get_latest_volume_id_available_by_uuid(options[:uuid]))
        puts "Volume found: #{volume_id}"
      elsif (snapshot_id = ec2.get_latest_snapshot_id_by_uuid(options[:uuid]))
        puts "Snapshot found: #{snapshot_id}"
      else
        puts "No snapshot found. An empty #{options[:type]} volume will be created of #{options[:size]} GB."
      end

      if !volume_id
        puts 'Creating volume...'
        if (volume_id = ec2.create_volume(options[:size], options[:type], metadata[:availabilityZone], snapshot_id))
          puts "Volume created: #{volume_id}"

          puts 'Tagging volume...'
          if ec2.tag_volume(volume_id, volume_name, options)
            puts 'Volume tagged.'
          else
            puts 'Volume failed tagging.'
          end
        end
      else
        puts 'Volume failed creation.'
        exit 1
      end

      if volume_id
        puts 'Attaching volume...'
        if ec2.attach_volume(volume_id, metadata[:instanceId], options[:device])
          puts 'Volume attached to instance.'
        else
          puts 'Volume attachment failed.'
          exit 1
        end
      end
    end

    def tag(options, metadata)
      ec2 = Stapler::Ec2.new(metadata[:region])

      puts 'Finding volumes...'
      if (volumes = ec2.get_volume_id_by_instance_id(metadata[:instanceId]))
        puts "Volumes found: #{volumes}"

        volumes.each do |volume_id|
          if ec2.tag_volume(volume_id, ec2.get_volume_name_by_volume_id(volume_id), options)
            puts "Volume #{volume_id} tagged."
          else
            puts 'Volume failed tagging.'
          end
        end
      else
        puts 'No volumes found.'
        exit 1
      end
    end
  end
end
