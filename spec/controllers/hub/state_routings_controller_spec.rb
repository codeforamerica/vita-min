require "rails_helper"

describe Hub::StateRoutingsController do
  describe "before_actions" do
    let(:user) { create :admin_user }

    before do
      sign_in user
    end

    let!(:florida_srt_1) { create(:state_routing_target, state_abbreviation: "FL", target: create(:coalition)) }
    let!(:florida_srt_2) { create(:state_routing_target, state_abbreviation: "FL", target: create(:coalition)) }
    let!(:florida_srt_3) { create(:state_routing_target, state_abbreviation: "FL", target: create(:organization)) }

    let!(:cali_srt) { create(:state_routing_target, state_abbreviation: "CA", target: create(:coalition)) }
    let!(:cali_srt_2) { create(:state_routing_target, state_abbreviation: "CA", target: create(:organization)) }

    it "loads the state routing targets on edit" do
      get :edit, params: { state: "FL" }

      expect(assigns(:coalition_srts)).to eq [florida_srt_1, florida_srt_2]
      expect(assigns(:independent_org_srts)).to eq [florida_srt_3]
    end

    it "loads the state routing targets on update" do
      put :update, params: { state: "FL", hub_state_routing_form: { state_routing_fraction_attributes: "some_params" } }

      expect(assigns(:coalition_srts)).to eq [florida_srt_1, florida_srt_2]
      expect(assigns(:independent_org_srts)).to eq [florida_srt_3]
    end
  end

  describe '#index' do
    context "when not authenticated" do
      it "redirects to login" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated as a user type without access to VitaPartnerState objects" do
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
        create(:vita_partner_state, state: "CA", routing_fraction: 0.5)
        create(:vita_partner_state, state: "CA", routing_fraction: 0.3)
        create(:vita_partner_state, state: "TX", routing_fraction: 0.3)
        create(:vita_partner_state, state: "AZ", routing_fraction: 0.5)

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

    it "instantiates the form" do
      get :edit, params: { state: "FL" }

      expect(response).to render_template :edit
      expect(Hub::StateRoutingForm).to have_received(:new)
    end
  end

  describe '#update' do
    let(:user) { create :admin_user }
    let(:vps1) { create(:vita_partner_state, state: "FL", routing_fraction: 0.6) }
    let(:vps2) { create(:vita_partner_state, state: "FL", routing_fraction: 0.5) }

    before do
      sign_in user
    end

    context "when the form is not valid" do
      it "creates a flash alert and renders edit with form errors" do

      end
    end

    context "when the form is valid" do
      it "calls save and redirects to edit" do

      end
    end

    xcontext "when the state routing fractions do not add up to 1" do
      it "renders the edit page with an error" do
        put :update, params: {
          state: "FL",
          "hub_state_routing_form" => {
            "vita_partner_states_attributes" => {
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

    xcontext "when the state routing fractions add up to 1" do
      it "saves the new values to the vps objects" do
        put :update, params: {
          state: "FL",
          "hub_state_routing_form" => {
            "vita_partner_states_attributes" => {
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

    xcontext "when there are duplicate organizations" do
      it "renders the edit page with an error" do
        put :update, params: {
          state: "FL",
          "hub_state_routing_form" => {
            "vita_partner_states_attributes" => {
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
end