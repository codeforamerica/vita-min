require "rails_helper"

describe TimeHelper do
  describe "#timezone_select_options" do
    it "returns a list of us time zones, readable for display first olson second" do
      expect(helper.timezone_select_options).to include(["Pacific Time (US & Canada)", "America/Los_Angeles"])
    end
  end

  describe "#formatted_datetime" do
    it "returns a string formatted to show the date and the time with zone" do
      Time.use_zone("America/Los_Angeles") do
        # in_time_zone coerces from -0800 -> PST
        test_date = Time.zone.local(2004, 11, 24, 01, 04, 44).in_time_zone("America/Los_Angeles")
        expect(helper.formatted_datetime(test_date)).to include("Nov 24, 2004  1:04 AM PST")
      end
    end
  end
end