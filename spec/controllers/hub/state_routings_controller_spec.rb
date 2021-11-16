require "rails_helper"

describe Hub::StateRoutingsController do
  describe '#index' do
    context "when not authenticated" do
      it "redirects to login" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated as a user type without access to StateRoutingTarget objects" do
      let(:user) { create :team_member_user }
      before do
        sign_in user
      end

      it "is forbidden" do
        get :index
        expect(response).to be_forbidden
      end
    end

    context "as an authenticated user" do
      let(:user) { create :admin_user }

      before do
        create(:state_routing_target, state: "CA", routing_fraction: 0.5)
        create(:state_routing_target, state: "CA", routing_fraction: 0.3)
        create(:state_routing_target, state: "TX", routing_fraction: 0.3)
        create(:state_routing_target, state: "AZ", routing_fraction: 0.5)

        sign_in user
      end

      it "assigns state_routings grouped by state in ASC order" do
        get :index
        expect(assigns(:state_routings).length).to eq(3)
        expect(assigns(:state_routings).first[0]).to eq("AZ")
        expect(assigns(:state_routings).first[1].length).to eq(1)
        expect(assigns(:state_routings).second[0]).to eq("CA")
        expect(assigns(:state_routings).second[1].length).to eq(2)
      end

      context "without explicit routing rules for a state" do
        render_views
        it "still displays the state in the view" do
          get :index
          expect(response.body).to include("Alaska")
        end
      end
    end
  end

  describe '#edit' do
    let(:user) { create :admin_user }

    before do
      sign_in user
      allow(Hub::StateRoutingForm).to receive(:new)
    end

    it "the current state abbreviation to the form object" do
      get :edit, params: { state: "FL" }

      expect(response).to render_template :edit
      expect(Hub::StateRoutingForm).to have_received(:new).with(state: "FL")
    end
  end

  describe '#update' do
    let(:user) { create :admin_user }
    let(:vps1) { create(:state_routing_target, state: "FL", routing_fraction: 0.6) }
    let(:vps2) { create(:state_routing_target, state: "FL", routing_fraction: 0.5) }

    before do
      sign_in user
    end

    context "when the state routing fractions do not add up to 1" do
      it "renders the edit page with an error" do
        put :update, params: {
          state: "FL",
          "hub_state_routing_form" => {
            "state_routing_targets_attributes" => {
              vps1.id => {
                routing_percentage: 60
              },
              vps2.id => {
                routing_percentage: 50
              }
            }
          }
        }
        expect(response).to render_template :edit
        expect(flash[:alert]).to eq "Please fix indicated errors and try again."
      end
    end

    context "when the state routing fractions add up to 1" do
      it "saves the new values to the vps objects" do
        put :update, params: {
          state: "FL",
          "hub_state_routing_form" => {
            "state_routing_targets_attributes" => {
              "0" => {
                vita_partner_id: vps1.vita_partner.id,
                routing_percentage: 60
              },
              "1" => {
                vita_partner_id: vps2.vita_partner.id,
                routing_percentage: 40
              }
            }
          }
        }

        expect(response).to redirect_to edit_hub_state_routing_path(state: "FL")
        expect(vps1.reload.routing_fraction).to eq 0.6
        expect(vps2.reload.routing_fraction).to eq 0.4
      end
    end

    context "when there are duplicate organizations" do
      it "renders the edit page with an error" do
        put :update, params: {
          state: "FL",
          "hub_state_routing_form" => {
            "state_routing_targets_attributes" => {
              "0" => {
                id: 1,
                routing_percentage: 40,
                vita_partner_id: 2
              },
              "1" => {
                id: 2,
                routing_percentage: 40,
                vita_partner_id: 1
              },
              "new" => {
                vita_partner_id: 1,
                routing_percentage: 20,
              }
            }
          }
        }
        expect(response).to render_template :edit
        expect(flash[:alert]).to eq "Please fix indicated errors and try again."
      end
    end
  end

  describe '#destory' do
    let(:user) { create :admin_user }
    let(:routing_fraction) { 0.0 }
    let!(:state_routing_target) { create :state_routing_target, routing_fraction: routing_fraction, state: "FL" }

    before do
      sign_in user
    end

    context "when vita partner state has a routing percentage of 0" do
      it "deletes the vita partner state and redirects to the state routing page" do
        expect {
          delete :destroy, params: { id: state_routing_target.id, state: "FL" }
        }.to change(StateRoutingTarget, :count).by(-1)
        expect(response).to redirect_to(edit_hub_state_routing_path(state: "FL"))
      end
    end

    context "when vita partner state with matching id cannot be found" do
      it "redirects to state routing edit page with an error message" do
        delete :destroy, params: { id: 90000, state: "FL" }

        expect(response).to redirect_to(edit_hub_state_routing_path(state: "FL"))
        expect(flash[:alert]).to eq "Matching routing entry for FL could not be found. Try again."
      end
    end

    context "when vita partner state does not have a routing percentage of 0" do
      let!(:routing_fraction) { 0.4 }

      it "shows an error message and redirects to edit" do
        delete :destroy, params: { id: state_routing_target.id, state: "FL" }

        expect(flash[:alert]).to eq "To delete a persisted routing rule, routing percentage must be 0%."
        expect(response).to redirect_to(edit_hub_state_routing_path(state: "FL"))
      end
    end
  end
end