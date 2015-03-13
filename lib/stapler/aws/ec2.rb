require 'timeout'
require 'aws-sdk'

module Stapler
  class Ec2
    def initialize(region)
      Aws.config = {
        region: region
      }

      @ec2 = Aws::EC2::Client.new
    end

    def get_latest_snapshot_id_by_uuid(uuid)
      begin
        @ec2.describe_snapshots(
          filters: [
            { name: "tag-key",   values: [ "UUID" ] },
            { name: "tag-value", values: [ uuid ] },
            { name: "status",    values: [ "completed" ] }
          ]
        ).data.snapshots.sort_by { |snapshot| snapshot.start_time }.last.snapshot_id
      rescue NoMethodError
        nil
      end
    end

    def get_instance_name_by_instance_id(instance_id)
      Aws::EC2::Client.new.describe_tags(
        filters: [
          { name: 'resource-id', values: [ instance_id ] },
          { name: 'key',         values: ['Name'] }
        ]
      ).data.tags.first.value
    end

    def create_volume(size, availability_zone, snapshot_id = nil, volume_type = 'gp2')
      resp = @ec2.create_volume(
        size: size,
        snapshot_id:       snapshot_id,
        availability_zone: availability_zone,
        volume_type:       volume_type
      )

      begin
        Timeout::timeout(600) {
          while @ec2.describe_volumes(volume_ids: [ resp.volume_id ]).data.volumes.first.state != 'available'
            sleep 5
          end
          resp.volume_id
        }
      rescue Timeout::Error
        nil
      end
    end

    def tag_volume(volume_id, volume_name, project, application, uuid)
      @ec2.create_tags(
        resources: [ volume_id ],
        tags: [
          { key: "Name",        value: volume_name },
          { key: "Project",     value: project },
          { key: "Application", value: application },
          { key: "UUID",        value: uuid },
          { key: "ManagedBy",   value: "Stapler" }
        ]
      )
    end

    def attach_volume(volume_id, instance_id, device)
      @ec2.attach_volume(
        volume_id:   volume_id,
        instance_id: instance_id,
        device:      device
      )
    end
  end
end
