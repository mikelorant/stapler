require 'uri'
require 'net/http'
require 'json'

module Stapler
  class Configuration
    attr_accessor :metadata

    def get_metadata
      begin
        Timeout::timeout(2) {
          url = URI.parse('http://169.254.169.254/latest/dynamic/instance-identity/document')
          resp = Net::HTTP.get_response(url)

          return nil if resp.code != "200"

          JSON.parse(resp.body, :symbolize_names => true)
        }
      rescue Timeout::Error
        JSON.parse(File.read('simulate.json'), :symbolize_names => true)
      end
    end
  end
end
