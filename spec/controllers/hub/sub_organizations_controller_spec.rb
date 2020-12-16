require 'rails_helper'

RSpec.describe Hub::SubOrganizationsController, type: :controller do
  describe "#update" do
    let!(:vita_partner) { create :vita_partner }
    let(:user) { create :admin_user }
    let(:params) { { id: vita_partner } }

    it_behaves_like :a_post_action_for_admins_only, action: :update

    context "as an authenticated admin user" do
      before { sign_in(user) }

      it "accepts a name and redirects to the parent organization's show page" do
        expect do
          put :update, params: { id: vita_partner.id,
                                 hub_sub_organization_form:
                                  { name: "City Hall Tax Help Center" } }
        end.to change(VitaPartner, :count).by(1)

        city_hall_tax_help_center = VitaPartner.last
        expect(city_hall_tax_help_center.name).to eq("City Hall Tax Help Center")
        expect(city_hall_tax_help_center.parent_organization).to eq(vita_partner)

        expect(response).to redirect_to(hub_vita_partner_path(id: city_hall_tax_help_center.parent_organization.id))
      end

      it "accepts a name and display name and redirects to parent organization's show page" do
        expect do
          put :update, params: { id: vita_partner.id,
                                 hub_sub_organization_form: {
                                     name: "City Hall Tax Help Center",
                                 } }
        end.to change(VitaPartner, :count).by(1)

        city_hall_tax_help_center = VitaPartner.last
        expect(city_hall_tax_help_center.name).to eq("City Hall Tax Help Center")
        expect(city_hall_tax_help_center.parent_organization).to eq(vita_partner)

        expect(response).to redirect_to(hub_vita_partner_path(id: city_hall_tax_help_center.parent_organization.id))
      end

      context "with invalid params" do
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
  end

  describe "#edit" do
    let!(:vita_partner) { create :vita_partner }
    let(:user) { create :admin_user }
    let(:params) { { id: vita_partner } }

    it_behaves_like :a_get_action_for_admins_only, action: :edit

    context "as an authenticated user" do
      before { sign_in(user) }

      it "shows a form" do
        get :edit, params: params

        expect(assigns(:form)).to be_present
      end
    end
  end
end
