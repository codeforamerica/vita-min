require "rails_helper"

RSpec.describe StateFile::Questions::NyThirdPartyDesigneeController do
  let(:intake) { create :state_file_ny_intake }

  before do
    sign_in intake
  end

  describe ".show?" do
    context "when the client has a third party designee indicator is false" do
      before do
        intake.direct_file_data.third_party_designee = "false"
      end
      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

  context "when the client has a third party designee indicator is true" do
    before do
      intake.direct_file_data.third_party_designee = "true"
    end
    it "returns true" do
      expect(described_class.show?(intake)).to eq true
    end
  end
end
