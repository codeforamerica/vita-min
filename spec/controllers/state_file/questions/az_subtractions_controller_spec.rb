require "rails_helper"

RSpec.describe StateFile::Questions::AzSubtractionsController do
  let(:intake) { create :state_file_az_intake }
  before do
    sign_in intake
  end

  describe "#update" do
    let(:form_params) do
      {
        state_file_az_subtractions_form: {
          armed_forces_member: "yes",
          armed_forces_wages_amount: "100",
          tribal_member: "yes",
          tribal_wages_amount: "200"
        }
      }
    end

    it "saves form params correctly" do
      post :update, params: form_params
      expect(response).to be_redirect

      intake.reload

      expect(intake).to be_armed_forces_member_yes
      expect(intake.armed_forces_wages_amount).to eq(100)
      expect(intake).to be_tribal_member_yes
      expect(intake.tribal_wages_amount).to eq(200)
    end
  end

  describe "#show" do
    context "with wages, salaries, and tips greater than 0" do
      it "returns true" do
        allow(intake.direct_file_data).to receive(:fed_wages_salaries_tips).and_return(21_000)
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "without wages, salaries, and tips" do
      it "returns false" do
        allow(intake.direct_file_data).to receive(:fed_wages_salaries_tips).and_return(nil)
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "with wages, salaries, and tips equal to 0" do
      it "returns false" do
        allow(intake.direct_file_data).to receive(:fed_wages_salaries_tips).and_return(0)
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

end