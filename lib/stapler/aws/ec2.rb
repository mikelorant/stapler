require 'timeout'
require 'aws-sdk'

module Stapler
  # Stapler::Ec2
  class Ec2
    def initialize(region)
      Aws.config = {
        region: region
      }

      @ec2 = Aws::EC2::Client.new
    end

    def get_latest_volume_id_available(uuid)
      filters = [
        { name: 'tag-key',   values: ['UUID'] },
        { name: 'tag-value', values: [uuid] }
      ]

      @ec2.describe_volumes(filters: filters).data.volumes.sort_by(&:create_time).find_all { |volume| volume.state == 'available' }.last.volume_id
    rescue NoMethodError
      nil
    end

    def get_latest_snapshot_id(uuid)
      filters = [
        { name: 'tag-key',   values: ['UUID'] },
        { name: 'tag-value', values: [uuid] },
        { name: 'status',    values: ['completed'] }
      ]

      @ec2.describe_snapshots(filters: filters).data.snapshots.sort_by(&:start_time).last.snapshot_id
    rescue NoMethodError
      nil
    end

    def get_instance_name(instance_id)
      filters = [
        { name: 'resource-id', values: [instance_id] },
        { name: 'key',         values: ['Name'] }
      ]

      @ec2.describe_tags(filters: filters).data.tags.first.value
    rescue NoMethodError
      nil
    end

    def get_volume_id(instance_id)
      filters = [
        { name: 'attachment.instance-id', values: [instance_id] }
      ]

      @ec2.describe_volumes(filters: filters).data.volumes.collect(&:volume_id)
    end

    def get_volume_name(volume_id)
      attachment = @ec2.describe_volumes(volume_ids: [volume_id]).data.volumes.first.attachments.first
      instance_name = get_instance_name(attachment.instance_id)

      "#{instance_name}-#{attachment.device}"
    end

    def get_volume_region(volume_id)
      @ec2.describe_volumes(volume_ids: [volume_id]).data.volumes.first.availability_zone
    end

    def create_volume(size, volume_type, availability_zone, snapshot_id = nil)
      resp = @ec2.create_volume(
        size:              size,
        snapshot_id:       snapshot_id,
        availability_zone: availability_zone,
        volume_type:       volume_type
      )

      begin
        Timeout.timeout(600) do
          while @ec2.describe_volumes(volume_ids: [resp.volume_id]).data.volumes.first.state != 'available'
            sleep 5
          end
          resp.volume_id
        end
      rescue Timeout::Error
        nil
      end
    end

    def create_snapshot(volume_id)
      snapshot_id = @ec2.create_snapshot(volume_id: volume_id).snapshot_id
      tags = @ec2.describe_volumes(volume_ids: [volume_id]).data.volumes.first.tags

      tag_snapshot(snapshot_id, tags)

      begin
        Timeout.timeout(600) do
          while @ec2.describe_snapshots(snapshot_ids: [snapshot_id]).data.snapshots.first.state != 'completed'
            sleep 5
          end
          snapshot_id
        end
      rescue Timeout::Error
        nil
      end
    end

    def tag_volume(volume_id, volume_name, options)
      tags = [
        { key: 'Name',         value: volume_name },
        { key: 'Project',      value: options[:project] },
        { key: 'Environment',  value: options[:environment] },
        { key: 'Creator',      value: options[:creator] },
        { key: 'Expires',      value: options[:expires] },
        { key: 'Service',      value: options[:service] },
        { key: 'Management',   value: options[:management] },
        { key: 'UUID',         value: options[:uuid] },
        { key: 'SnapInterval', value: options[:snapinterval] },
        { key: 'Detached',     value: options[:preserve] }
      ]

      tags = tags.reject { |tag| tag[:value].nil? }

      @ec2.create_tags(
        resources: [volume_id],
        tags: tags
      )
    rescue Aws::EC2::Errors::RequestLimitExceeded
      nil
    end

    def tag_snapshot(snapshot_id, tags)
      @ec2.create_tags(
        resources: [snapshot_id],
        tags: tags.map(&:to_h)
      )
    rescue Aws::EC2::Errors::RequestLimitExceeded
      nil
    end

    def attach_volume(volume_id, instance_id, device)
      @ec2.attach_volume(
        volume_id:   volume_id,
        instance_id: instance_id,
        device:      device
      )

      begin
        Timeout.timeout(600) do
          while @ec2.describe_volumes(volume_ids: [volume_id]).data.volumes.first.attachments.first.state != 'attached'
            sleep 5
          end
          volume_id
        end
      rescue Timeout::Error
        nil
      end
    end
  end
end
