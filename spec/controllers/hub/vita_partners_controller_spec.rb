require 'rails_helper'

RSpec.describe Hub::VitaPartnersController, type: :controller do
  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "for orgs with sub-organizations, i.e., sites" do
      let(:user) { create(:admin_user, vita_partner: vita_partner1) }
      let!(:vita_partner1) { create(:vita_partner, name: "Vita Partner 1") }
      let!(:vita_partner1_site) { create(:vita_partner, name: "Library Tax Help of Vita Partner 1", parent_organization: vita_partner1) }
      let!(:vita_partner2) { create(:vita_partner, name: "Vita Partner 2") }

      before do
        sign_in(user)
      end

      it "shows only top-level organizations, not sites" do
        get :index

        expect(assigns(:vita_partners)).to include(vita_partner1)
        expect(assigns(:vita_partners)).to include(vita_partner2)
        expect(assigns(:vita_partners)).not_to include(vita_partner1_site)
      end
    end
  end

  describe "#show" do
    let(:vita_partner) { create :vita_partner }
    let(:params) { {id: vita_partner} }

    it_behaves_like :a_get_action_for_admins_only, action: :show

    context "sub-organizations" do
      let(:user) { create(:admin_user, vita_partner: vita_partner)}
      let!(:vita_partner_site) { create(:vita_partner, name: "Library Tax Help of Vita Partner", parent_organization: vita_partner) }

      before do
        sign_in(user)
      end

      it "shows the sub-organizations for an organization" do
        get :show, params: params

        expect(assigns(:vita_partner)).to eq(vita_partner)
        expect(assigns(:sub_organizations)).to include(vita_partner_site)
      end
    end

    context "as an authenticated admin user" do
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
