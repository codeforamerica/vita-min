require 'rails_helper'

RSpec.describe CaseManagement::SubOrganizationsController, type: :controller do
  describe "#update" do
    let!(:vita_partner) { create :vita_partner }
    let(:user) { create :beta_tester, vita_partner: vita_partner }
    let(:params) { { id: vita_partner } }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "with valid params" do
      before { sign_in(user) }

      it "accepts a display_name and redirects to the parent organization's show page" do
        expect do
          put :update, params: { id: vita_partner.id,
                                 case_management_sub_organization_form:
                                  { display_name: "City Hall Tax Help Center" } }
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
          put :update,
              params: {
                id: vita_partner.id,
                case_management_sub_organization_form:
                  { display_name: "" },
              }
        end.not_to change(VitaPartner, :count)

        expect(response).to be_ok
        expect(assigns(:form).errors).to be_present
      end
    end
  end

  describe "#edit" do
    let!(:vita_partner) { create :vita_partner }
    let(:user) { create :beta_tester, vita_partner: vita_partner }
    let(:params) { { id: vita_partner } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as a signed-in beta user" do
      before { sign_in(user) }

      it "shows a form" do
        get :edit, params: params

        expect(assigns(:form)).to be_present
      end
    end
  end
end
