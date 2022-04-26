require "rails_helper"

describe Ctc::Questions::SpouseDriversLicenseController do
  let(:intake) { create :ctc_intake }

  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_ctc_clients_only, action: :edit

    context "as an authenticated ctc client" do
      before do
        sign_in intake.client
      end

      it "renders edit template" do
        get :edit, params: {}
        expect(response).to render_template :edit
      end
    end
  end

  describe "#update" do
    it_behaves_like :a_post_action_for_authenticated_ctc_clients_only, action: :update
  end
end
