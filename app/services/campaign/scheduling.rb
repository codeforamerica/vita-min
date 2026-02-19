module Campaign
  module Scheduling
    def next_business_hour_start
      now = Time.current.in_time_zone("America/New_York")

      # within business hours (8am-9pm) => start now
      if now.hour >= 8 && now.hour < 21
        return Time.current
      end

      # before 8am => schedule for 8am same day
      if now.hour < 8
        return now.change(hour: 8, min: 0, sec: 0).in_time_zone('UTC')
      end

      # after 9pm => schedule for 8am next day
      (now + 1.day).change(hour: 8, min: 0, sec: 0).in_time_zone('UTC')
    end
  end
end
