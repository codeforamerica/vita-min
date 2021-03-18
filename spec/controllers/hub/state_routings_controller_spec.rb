require "rails_helper"

describe Hub::StateRoutingsController do
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
end