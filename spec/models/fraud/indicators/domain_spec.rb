# == Schema Information
#
# Table name: fraud_indicators_domains
#
#  id           :bigint           not null, primary key
#  activated_at :datetime
#  name         :string
#  risky        :boolean
#  safe         :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_fraud_indicators_domains_on_risky  (risky)
#  index_fraud_indicators_domains_on_safe   (safe)
#
require "rails_helper"

describe Fraud::Indicators::Domain do
  context 'validations' do
    context "when the name does not have a period (is not a domain)" do
      it "is not valid" do
        instance = described_class.new(name: "gmail")
        expect(instance).not_to be_valid
        expect(instance.errors[:name]).to be_present
      end
    end

    context "when risky and safe are both set" do
      it "is not valid" do
        instance = described_class.new(name: "gmail.com", safe: true, risky: true)
        expect(instance).not_to be_valid
        expect(instance.errors[:safe]).to include("Only one of risky or safe are allowed")
        expect(instance.errors[:risky]).to include("Only one of risky or safe are allowed")
      end
    end

    context "when neither risky or safe are set" do
      it "is not valid" do
        instance = described_class.new(name: "gmail.com")
        expect(instance).not_to be_valid
        expect(instance.errors[:safe]).to include "One of risky or safe are required"
        expect(instance.errors[:risky]).to include "One of risky or safe are required"
      end
    end
  end
end
