require 'rails_helper'

RSpec.describe CaseManagement::VitaPartnersController, type: :controller do
  describe "#show" do
    let(:vita_partner) { create :vita_partner }
    let(:params) { {id: vita_partner} }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show
    it_behaves_like :a_get_action_for_beta_testers_only, action: :show

    context "as an authenticated beta tester who is not an admin" do
      let(:user) { create :beta_tester, vita_partner: vita_partner }
      let(:other_vita_partner) { create :vita_partner}
      before { sign_in(user) }

      it "can access if user has matching vita partner" do
        get :show, params: params

        expect(response).to be_ok
        expect(assigns(:vita_partner)).to eq(vita_partner)
      end

      it "can't access if user has a different vita partner" do
        get :show, params: {id: other_vita_partner}

        expect(response.status).to be 403
      end
    end

    context "as an authenticated beta tester admin user" do
      let(:user) { create :admin_user }
      before { sign_in(user) }
      let(:other_vita_partner) { create :vita_partner }

      it "can access any vita partner show page" do
        get :show, params: { id: other_vita_partner }

        expect(response).to be_ok
        expect(assigns(:vita_partner)).to eq(other_vita_partner)
      end
    end
  end
end