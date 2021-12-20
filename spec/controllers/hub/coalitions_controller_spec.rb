require "rails_helper"

RSpec.describe Hub::CoalitionsController, type: :controller do
  let(:admin_user) { create :admin_user }
  let(:coalition) { create(:coalition) }
  let(:params) do
    {
      id: coalition.id,
      coalition: {
        name: "Koala Coalition's New Name",
      },
      state_routing_targets: {
        states: "AL,OH,UT"
      }
    }
  end
  let(:form) { double(Hub::CoalitionForm) }

  before do
    allow(Hub::CoalitionForm).to receive(:new).and_return(form)
  end

  describe "#new" do
    it_behaves_like :a_get_action_for_admins_only, action: :new
  end

  describe "#create" do
    it_behaves_like :a_post_action_for_admins_only, action: :create

    context "as an authenticated admin user" do
      before { sign_in admin_user }

      context "with valid params" do
        before { allow(form).to receive(:save).and_return true }

        it "redirects to the organizations page" do
          post :create, params: params
          expect(response).to redirect_to hub_organizations_path
        end
      end

      context "with invalid params" do
        before { allow(form).to receive(:save).and_return false }

        it "renders the new page (with errors)" do
          post :create, params: params
          expect(response).to render_template :new
        end
      end
    end
  end

  describe "#edit" do
    it_behaves_like :a_get_action_for_admins_only, action: :edit
  end

  describe "#update" do
    it_behaves_like :a_post_action_for_admins_only, action: :update

    context "as an authenticated admin user" do
      before { sign_in admin_user }

      context "with valid params" do
        before { allow(form).to receive(:save).and_return true }
        it "reloads the page" do
          post :update, params: params

          expect(flash.now[:notice]).to eq "Changes saved"
          expect(response).to redirect_to edit_hub_coalition_path(id: coalition.id)
        end
      end

      context "with invalid params" do
        before { allow(form).to receive(:save).and_return false }

        it "re-renders edit with an error message" do
          post :update, params: params

          expect(flash.now[:alert]).to eq "Please fix indicated errors and try again."
          expect(response).to render_template :edit
        end
      end
    end
  end
end
