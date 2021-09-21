require "rails_helper"

describe EfileSecurityInformation do
  describe "#fraud_suspected?" do
    let(:efile_security_info) { create(:efile_security_information, recaptcha_score: score, client: create(:client)) }
    let(:score) { 0.8 }

    context "with a non-zero recaptcha score" do
      it "returns false" do
        expect(efile_security_info.fraud_suspected?).to eq(false)
      end
    end

    context "with a nil recaptcha score" do
      let(:score) { nil }
      it "returns false" do
        expect(efile_security_info.fraud_suspected?).to eq(false)
      end
    end

    context "with a 0.0 recaptcha score" do
      let(:score) { 0.0 }
      it "returns true" do
        expect(efile_security_info.fraud_suspected?).to eq(true)
      end
    end
  end
end
