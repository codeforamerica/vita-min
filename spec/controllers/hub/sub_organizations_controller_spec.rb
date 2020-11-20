require 'rails_helper'

RSpec.describe Hub::SubOrganizationsController, type: :controller do
  describe "#update" do
    let(:user) { create :user_with_membership }
    let!(:vita_partner) { user.memberships.first.vita_partner }
    let(:params) { { id: vita_partner } }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "with valid params" do
      before { sign_in(user) }

      it "accepts a name (and uses for the display name, too) and redirects to the parent organization's show page" do
        expect do
          put :update, params: { id: vita_partner.id,
                                 hub_sub_organization_form:
                                  { name: "City Hall Tax Help Center" } }
        end.to change(VitaPartner, :count).by(1)

        city_hall_tax_help_center = VitaPartner.last
        expect(city_hall_tax_help_center.name).to eq("City Hall Tax Help Center")
        expect(city_hall_tax_help_center.display_name).to eq("City Hall Tax Help Center")
        expect(city_hall_tax_help_center.parent_organization).to eq(vita_partner)

        expect(response).to redirect_to(hub_vita_partner_path(id: city_hall_tax_help_center.parent_organization.id))
      end

      it "accepts a name and display name and redirects to parent organization's show page" do
        expect do
          put :update, params: { id: vita_partner.id,
                                 hub_sub_organization_form: {
                                     name: "City Hall Tax Help Center",
                                     display_name: "City Hall Tax Help Center (Denver)"
                                 } }
        end.to change(VitaPartner, :count).by(1)

        city_hall_tax_help_center = VitaPartner.last
        expect(city_hall_tax_help_center.name).to eq("City Hall Tax Help Center")
        expect(city_hall_tax_help_center.display_name).to eq("City Hall Tax Help Center (Denver)")
        expect(city_hall_tax_help_center.parent_organization).to eq(vita_partner)

        expect(response).to redirect_to(hub_vita_partner_path(id: city_hall_tax_help_center.parent_organization.id))
      end
    end

    context "with invalid params" do
      before { sign_in(user) }

      it "re-renders the form with the errors" do
        expect do
          put :update,
              params: {
                id: vita_partner.id,
                hub_sub_organization_form:
                  { name: "" },
              }
        end.not_to change(VitaPartner, :count)

        expect(response).to be_ok
        expect(assigns(:form).errors).to be_present
      end
    end
  end

  describe "#edit" do
    let(:user) { create :user_with_membership }
    let!(:vita_partner) { user.memberships.first.vita_partner }
    let(:params) { { id: vita_partner } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before { sign_in(user) }

      it "shows a form" do
        get :edit, params: params

        expect(assigns(:form)).to be_present
      end
    end
  end
end
