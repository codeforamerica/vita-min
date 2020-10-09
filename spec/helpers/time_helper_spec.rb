require "rails_helper"

describe TimeHelper do
  describe "#timezone_select_options" do
    it "returns a list of us time zones, readable for display first olson second" do
      expect(helper.timezone_select_options).to include(["Pacific Time (US & Canada)", "America/Los_Angeles"])
    end
  end
end