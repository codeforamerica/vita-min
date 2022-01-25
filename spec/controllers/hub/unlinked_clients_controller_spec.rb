require 'rails_helper'

RSpec.describe Hub::UnlinkedClientsController, requires_default_vita_partners: true do
  describe "#index" do
    it_behaves_like :a_get_action_for_admins_only, action: :index

    context "as an admin" do
      let(:user) { create(:admin_user) }
      let!(:national_client) { create(:client, vita_partner: VitaPartner.client_support_org) }
      let!(:unrelated_client) { create(:client, vita_partner: create(:organization)) }

      before do
        sign_in user
      end

      it "shows clients from national org" do
        get :index
        expect(assigns(:clients)).to match_array([national_client])
      end

      context "sorting by updated_at" do
        context "with order=desc" do
          it "sorts descending" do
            get :index, params: { order: "desc" }

            expect(assigns(:sort_column)).to eq("updated_at")
            expect(assigns(:sort_order)).to eq("desc")
          end
        end

        context "with any other order value" do
          it "sorts ascending" do
            get :index, params: { order: "other" }

            expect(assigns(:sort_column)).to eq("updated_at")
            expect(assigns(:sort_order)).to eq("asc")
          end
        end
      end
    end
  end
end
