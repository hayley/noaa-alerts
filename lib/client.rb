require "alert"
require "httparty"

module Noaa
  class Client
    attr_reader :alerts

    def initialize(location)
      @alerts = []
      fetch_alerts_for(location)
    end

    private

    def fetch_alerts_for(location)
      catalog = HTTParty.get("http://alerts.weather.gov/cap/#{location}.php?x=0", format: :xml)
      handle_catalog(catalog)
    end

    def handle_catalog(catalog)
      entries = catalog['feed']['entry']
      entries = [entries] unless entries.kind_of?(Array)
      entries.each do |entry|
        if entry['id'].start_with?('//')
          url = "http:#{entry['id']}"
        else
          url = entry['id']
        end
        item = HTTParty.get(url, format: :xml)['alert']
        alert = Noaa::Alert.new(entry['id'], item)
        @alerts << alert unless alert.description.empty?
      end
    end
  end
end
