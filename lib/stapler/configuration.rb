# Stapler::Configuration

require 'uri'
require 'net/http'
require 'json'

module Stapler
  # Stapler::Configuration
  class Configuration
    def metadata
      Timeout.timeout(2) do
        url = URI.parse('http://169.254.169.254/latest/dynamic/instance-identity/document')
        resp = Net::HTTP.get_response(url)

        return nil if resp.code != '200'

        JSON.parse(resp.body, symbolize_names: true)
      end
    rescue Timeout::Error
      JSON.parse(File.read('simulate.json'), symbolize_names: true)
    end
  end
end
