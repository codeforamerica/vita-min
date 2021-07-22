require "rails_helper"

describe Ctc::Questions::ConfirmInformationController do
  let(:intake) { create :ctc_intake }

  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_ctc_clients_only, action: :edit

    context "as an authenticated client" do
      before do
        sign_in intake.client
      end

      context "when the TIN type is SSN" do
        it "shows SSN labels" do

        end
      end

      context "when the TIN type is ITIN" do
        it "shows ITIN labels" do

        end
      end

      context "when filng joint" do
        it "shows the spouse info" do

        end

        it "shows a field for the spouse's PIN" do

        end
      end

      context "when there are dependents" do
        it "shows dependents' info" do

        end
      end
    end
  end



  describe '#update' do
    it "redirects to ip_pin question" do
      put :update, {}
      expect(response).to redirect_to questions_ip_pin_path
    end
  end
end