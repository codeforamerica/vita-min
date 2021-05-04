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
        test_date = DateTime.new(2004, 11, 24, 01, 04, 44)
        expect(helper.formatted_datetime(test_date)).to include("Nov 24 1:04 AM")
      end
    end
  end

  describe "#business_days" do
    before do
      allow(DateTime).to receive(:now).and_return DateTime.new(2021, 5, 4)
    end

    it "returns a string formatted to the number of business days since the given date" do
      Time.use_zone("America/Los_Angeles") do
        test_date = Time.new(2021, 4, 28)
        expect(helper.business_days(test_date)).to eq("4 business days")
      end
    end

    it "correctly pluralizes the days" do
      Time.use_zone("America/Los_Angeles") do
        test_date = Time.new(2021, 5, 3)
        expect(helper.business_days(test_date)).to eq("1 business day")
      end
    end
  end

  describe "#displayed_timezone" do
    it "returns the readable for display timezone" do
      expect(helper.displayed_timezone("America/Los_Angeles")).to eq "Pacific Time (US & Canada)"
    end
    context "when there is no matching timezone" do
      it "returns nil" do
        expect(helper.displayed_timezone("something whack")).to eq nil
      end
    end
  end
end