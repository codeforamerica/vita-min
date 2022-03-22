module Efile
  class Timezone
    attr_reader :id, :relationship, :irs_enum

    def self.import(filename)
      @@timezones = begin
        us_timezones = ActiveSupport::TimeZone.us_zones.map { |tz| [tz.name, tz.tzinfo.name].uniq }.flatten.freeze
        overrides = IceNine.deep_freeze!(YAML.load_file("lib/timezone_overrides.yml"))
        overrides + us_timezones
      end
    end

    def self.all
      @@timezones
    end

    def self.list
      all.push(nil).freeze
    end
  end
end
