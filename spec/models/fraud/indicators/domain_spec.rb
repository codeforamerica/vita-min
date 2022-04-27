# == Schema Information
#
# Table name: fraud_indicators_domains
#
#  id           :bigint           not null, primary key
#  activated_at :datetime
#  deny         :boolean
#  name         :string
#  safe         :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_fraud_indicators_domains_on_deny  (deny)
#  index_fraud_indicators_domains_on_safe  (safe)
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

    context "when deny and safe are both set" do
      it "is not valid" do
        instance = described_class.new(name: "gmail.com", safe: true, deny: true)
        expect(instance).not_to be_valid
        expect(instance.errors[:safe]).to include("Only one of deny or safe are allowed")
        expect(instance.errors[:deny]).to include("Only one of deny or safe are allowed")
      end
    end

    context "when neither deny or safe are set" do
      it "is not valid" do
        instance = described_class.new(name: "gmail.com")
        expect(instance).not_to be_valid
        expect(instance.errors[:safe]).to include "One of deny or safe are required"
        expect(instance.errors[:deny]).to include "One of deny or safe are required"
      end
    end
  end
end
