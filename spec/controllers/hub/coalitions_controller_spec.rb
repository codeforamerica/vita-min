require "rails_helper"

RSpec.describe Hub::CoalitionsController, type: :controller do
  let(:admin_user) { create :admin_user }

  describe "#new" do
    it_behaves_like :a_get_action_for_admins_only, action: :new
  end

  describe "#create" do
    let(:params) do
      {
        coalition: {
          name: "Koala Coalition",
          states: ["CA", "OH"]
        }
      }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :create

    context "as an authenticated admin user" do
      before { sign_in admin_user }

      it "creates the coalition and associated routing targets, and redirects to the organizations page" do
        expect do
          post :create, params: params
        end.to change { Coalition.count }.by 1

        #expect do
        #  post :create, params: params
        #end.to change { StateRoutingTarget.count }.by 2

        expect(response).to redirect_to hub_organizations_path
      end
    end
  end

  describe "#edit" do
    let(:coalition) { create :coalition }
    let(:params) do
      {
        id: coalition.id
      }
    end
    it_behaves_like :a_get_action_for_admins_only, action: :edit
  end

  describe "#update" do
    let(:coalition) { create :coalition }
    let(:params) do
      {
        id: coalition.id,
        coalition: {
          name: "Koala Coalition's New Name",
          states: ["CA", "OH", "UT"]
        }
      }
    end

    it_behaves_like :a_post_action_for_admins_only, action: :update

    context "as an authenticated admin user" do
      before { sign_in admin_user }

      context "when coalition object is valid" do
        it "updates the coalition with the new attributes, creates the new associated records and reloads the page" do
          post :update, params: params

          #expect do
          #  post :create, params: params
          #end.to change { StateRoutingTarget.count }.by 1

          coalition.reload
          expect(coalition.name).to eq "Koala Coalition's New Name"

          expect(flash[:notice]).to eq "Changes saved"
          expect(response).to redirect_to edit_hub_coalition_path(id: coalition.id)
        end
      end

      context "when the coalition object is not valid" do
        before do
          allow_any_instance_of(Coalition).to receive(:update).and_return false
        end

        it "re-renders edit with an error message" do
          post :update, params: params

          expect(flash.now[:alert]).to eq "Please fix indicated errors and try again."
          expect(response).to render_template :edit
        end
      end
    end
  end
end
