require 'rails_helper'

RSpec.describe StateFile::Questions::EmailAddressController do
  describe ".show?" do
    context "when contact preference is email" do
      it "returns true" do
        intake = create(:state_file_az_intake, contact_preference: "email")
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when contact preference is not email" do
      it "returns false" do
        intake = create(:state_file_az_intake)
        expect(described_class.show?(intake)).to eq false
      end
    end
  end
end