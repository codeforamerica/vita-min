require 'rails_helper'

describe Portal::PrimarySignForm8879 do
  subject { described_class.new(tax_return, params) }

  let(:fake_ip) { IPAddr.new }
  let(:params) { {} }

  describe "validations" do
    let(:tax_return) { create :gyr_tax_return }
    let(:valid_params) {
      {
        primary_accepts_terms: "yes",
        primary_confirms_identity: "yes"
      }
    }

    subject { described_class.new(tax_return, valid_params) }

    it "can be valid" do
      expect(subject.valid?).to eq true
    end

    it "validates that primary_accepts_terms equals 'yes'" do
      subject.primary_accepts_terms = "no"

      subject.valid?

      expect(subject.errors[:primary_accepts_terms]).to be_present
    end

    it "validates that primary_confirms_identity equals 'yes'" do
      subject.primary_confirms_identity = "no"

      subject.valid?

      expect(subject.errors[:primary_confirms_identity]).to be_present
    end
  end

  describe ".permitted_params" do
    it "returns the permitted params for the form" do
      expect(described_class.permitted_params).to eq [:primary_accepts_terms, :primary_confirms_identity]
    end
  end

  context "when there is no form 8879 available on the tax return to sign" do
    it "raises an error" do
      expect { subject }.to raise_error StandardError
    end
  end

  context "#sign" do
    let(:tax_return) { create :gyr_tax_return }
    let(:params) { { primary_accepts_terms: 'yes', primary_confirms_identity: 'yes', ip: fake_ip } }

    context "when the form fails validation" do
      let(:params) { { primary_accepts_terms: 'no', primary_confirms_identity: 'yes', ip: fake_ip } }

      it "returns false" do
        expect(subject.sign).to eq false
      end
    end

    context "when the return is successfully signed" do
      it "returns true" do
        expect(tax_return).to receive(:sign_primary!).with(fake_ip).and_return(true)

        expect(subject.sign).to eq true
      end
    end

    context "when the signing process raises AlreadySignedError" do
      it "returns false and adds errors" do
        expect(tax_return).to receive(:sign_primary!).and_raise(AlreadySignedError)

        expect(subject.sign).to eq false
        expect(subject.errors[:transaction_failed]).to be_present
      end
    end

    context "when the signing process raises FailedToSignReturnError" do
      it "returns false and adds errors" do
        expect(tax_return).to receive(:sign_primary!).and_raise(FailedToSignReturnError)

        expect(subject.sign).to eq false
        expect(subject.errors[:transaction_failed]).to be_present
      end
    end

    context "when the signing process raises CombinePDF::ParsingError" do
      it "returns false and adds errors" do
        expect(tax_return).to receive(:sign_primary!).and_raise(CombinePDF::ParsingError)

        expect(subject.sign).to eq false
        expect(subject.errors[:transaction_failed]).to be_present
      end
    end
  end
end