# == Schema Information
#
# Table name: fraud_indicators_routing_numbers
#
#  id             :bigint           not null, primary key
#  activated_at   :datetime
#  bank_name      :string
#  routing_number :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
require "rails_helper"

describe Fraud::Indicators::RoutingNumber do
  describe "#riskylist" do
    before do
      described_class.create(routing_number: "123456789", bank_name: "Bank of Taxes", activated_at: DateTime.now)
      described_class.create(routing_number: "111111111", bank_name: "Bank of Money", activated_at: DateTime.now)
      described_class.create(routing_number: "111111112", bank_name: "Bank of Things", activated_at: nil)
    end

    it "returns a list of all activated routing_number entries" do
      expect(described_class.riskylist).to include "123456789"
      expect(described_class.riskylist).to include "111111111"
      expect(described_class.riskylist).not_to include "111111112"
    end
  end
end
