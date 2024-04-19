require 'rails_helper'

RSpec.describe StateFile::Questions::PhoneNumberSignUpController do
  describe ".show?" do
    context "when contact preference is text message" do
      it "returns true" do
        intake = create(:state_file_az_intake, contact_preference: "text")
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when contact preference is not text message" do
      it "returns false" do
        intake = create(:state_file_az_intake)
        expect(described_class.show?(intake)).to eq false
      end
    end
  end
end