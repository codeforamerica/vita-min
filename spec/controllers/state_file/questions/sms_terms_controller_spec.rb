require "rails_helper"

RSpec.describe StateFile::Questions::SmsTermsController do
  let(:intake) { create :state_file_md_intake }
  before do
    sign_in intake
  end
  describe "#show?" do
    context "when phone number is present" do
      let(:intake) { create :state_file_nj_intake, phone_number: "+15038675309" }
      it "shows" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when phone number is not present" do
      let(:intake) { create :state_file_nj_intake, phone_number: nil }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end
end