require "rails_helper"

RSpec.describe E164PhoneValidator do
  subject { described_class.new(attributes: [:phone_number]) }

  let!(:record) { OpenStruct.new(errors: ActiveModel::Errors.new(nil)) }
  before { subject.validate_each(record, :phone_number, value) }

  context "with a valid e164 Twilio US format phone number" do
    let(:value) { "+15005550006" }

    it "does not add an error" do
      expect(record.errors[:phone_number]).to be_blank
    end
  end

  context "with an e164 number lacking a plus sign" do
    let(:value) { "15005550006" }

    it "adds an error" do
      expect(record.errors[:phone_number]).to eq(["Please enter a valid phone number."])
    end
  end

  context "with a valid non-e164 format phone number" do
    let(:value) { "(500) 555-0006" }

    it "adds an error" do
      expect(record.errors[:phone_number]).to eq(["Please enter a valid phone number."])
    end
  end

  context "with a clearly invalid phone number" do
    let(:value) { "653423" }

    it "adds an error" do
      expect(record.errors[:phone_number]).to eq(["Please enter a valid phone number."])
    end
  end

  context "with a blank value" do
    let(:value) { " " }

    it "adds an error" do
      expect(record.errors[:phone_number]).to eq(["Please enter a valid phone number."])
    end
  end
end
