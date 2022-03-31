# == Schema Information
#
# Table name: timezone_indicators
#
#  id           :bigint           not null, primary key
#  activated_at :datetime
#  name         :string
#  override     :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "rails_helper"

describe Fraud::Indicators::Timezone do
  describe '.safelist' do
    before do
      create :timezone_indicator, name: "America/Chicago", activated_at: DateTime.now
      create :timezone_indicator, name: "Mexico/Tijuana", activated_at: nil
    end

    it "includes the names of all of the activated objects and nil" do
      expect(Fraud::Indicators::Timezone.safelist).to eq ["America/Chicago", nil]
    end
  end
end
