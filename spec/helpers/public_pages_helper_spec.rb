require "rails_helper"

RSpec.describe PublicPagesHelper do
  describe "#enable_online_intake?" do
    it "returns true" do
      expect(helper.enable_online_intake?).to eq(true)
    end
  end
end
