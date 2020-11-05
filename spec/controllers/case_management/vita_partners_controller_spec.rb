require 'rails_helper'

RSpec.describe CaseManagement::VitaPartnersController, type: :controller do
  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    it_behaves_like :a_get_action_for_beta_testers_only, action: :index

    context "for orgs with sub-organizations, i.e., sites" do
      let(:user) { create(:admin_user, vita_partner: vita_partner1)}
      let!(:vita_partner1) { create(:vita_partner, display_name: "Vita Partner 1") }
      let!(:vita_partner1_site) { create(:vita_partner, display_name: "Library Tax Help of Vita Partner 1", parent_organization: vita_partner1) }
      let!(:vita_partner2) { create(:vita_partner, display_name: "Vita Partner 2") }

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

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show
    it_behaves_like :a_get_action_for_beta_testers_only, action: :show

    context "sub-organizations" do
      let(:user) { create(:admin_user, vita_partner: vita_partner)}
      let!(:vita_partner_site) { create(:vita_partner, display_name: "Library Tax Help of Vita Partner", parent_organization: vita_partner) }

      before do
        sign_in(user)
      end

      it "shows the sub-organizations for an organization" do
        get :show, params: params

        expect(assigns(:vita_partner)).to eq(vita_partner)
        expect(assigns(:sub_organizations)).to include(vita_partner_site)
      end
    end

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

  describe "#create_sub_organization" do
    let!(:vita_partner) { create :vita_partner }
    let(:user) { create :beta_tester, vita_partner: vita_partner }
    let(:params) { { id: vita_partner } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :create_sub_organization
    it_behaves_like :a_get_action_for_beta_testers_only, action: :create_sub_organization

    context "as a signed-in beta user" do
      before { sign_in(user) }

      it "shows a form" do
        get :create_sub_organization, params: params

        expect(assigns(:form)).to be_present
      end
    end

    context "with valid params" do
      before { sign_in(user) }

      it "accepts a display_name and redirects to the parent organization's show page" do
        expect do
          post :create_sub_organization, params: { id: vita_partner.id,
                                                   case_management_sub_organization_form:
                                                       {display_name: "City Hall Tax Help Center" }}
        end.to change(VitaPartner, :count).by(1)

        city_hall_tax_help_center = VitaPartner.last
        expect(city_hall_tax_help_center.name).to eq("City Hall Tax Help Center")
        expect(city_hall_tax_help_center.display_name).to eq("City Hall Tax Help Center")
        expect(city_hall_tax_help_center.parent_organization).to eq(vita_partner)

        expect(response).to redirect_to(case_management_vita_partner_path(id: city_hall_tax_help_center.parent_organization.id))
      end
    end

    context "with invalid params" do
      before { sign_in(user) }

      it "re-renders the form with the errors" do
        expect do
          post :create_sub_organization,
               params: {
                 id: vita_partner.id,
                 case_management_sub_organization_form:
                 { display_name: "" },
               }
        end.not_to change(VitaPartner, :count)

        expect(response).to be_ok
      end
    end
  end
end
