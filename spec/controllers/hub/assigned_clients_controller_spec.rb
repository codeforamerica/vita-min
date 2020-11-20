require 'rails_helper'

RSpec.describe Hub::AssignedClientsController do
  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
  end

  context "as an authenticated user" do
    let(:vita_partner) { create(:vita_partner) }
    let(:user) { create(:user_with_org, vita_partner: vita_partner) }

    before { sign_in user}
    let!(:assigned_to_me) { create :client, vita_partner: vita_partner, intake: (create :intake), tax_returns: [(create :tax_return, assigned_user: user, status: "intake_in_progress")] }
    let!(:not_assigned_to_me) { create :client, vita_partner: vita_partner, intake: (create :intake), tax_returns: [(create :tax_return)] }

    it "should allow me to see only clients with tax returns assigned to me" do
      get :index
      expect(assigns(:clients)).to include assigned_to_me
      expect(assigns(:clients)).not_to include not_assigned_to_me
    end

    context "rendering" do
      render_views
      it "renders the clients table view" do
        get :index
        expect(response).to render_template "clients/index"
      end
    end

    context "filtering" do
      let!(:second_return) { create :tax_return, year: 2018, assigned_user: user, client: assigned_to_me, status: "intake_open" }

      context "filter always to me" do
        it "always filters to assigned to me" do
          get :index
          expect(assigns(:always_current_user_assigned)).to eq true
        end
      end

      context "filtering by status" do
        it "filters in with matching tax return (intake_in_progress)" do
          get :index, params: { status: "intake_in_progress" }
          expect(assigns(:clients)).to eq [assigned_to_me]
        end

        it "filters in with matching tax return (intake_open)" do
          get :index, params: { status: "intake_open" }
          expect(assigns(:clients)).to eq [assigned_to_me]
        end

        it "filters out" do
          get :index, params: { status: "review_in_review" }
          expect(assigns(:clients)).to eq []
        end
      end

      context "filtering by stage" do
        it "filters in" do
          get :index, params: { status: "intake" }
          expect(assigns(:clients)).to eq [assigned_to_me]
        end

        it "filters out" do
          get :index, params: { status: "prep" }
          expect(assigns(:clients)).to eq []
        end
      end

      context "filtering by tax return year" do
        let!(:return_3020) { create :tax_return, year: 3020, assigned_user: user, client: assigned_to_me, status: "intake_open" }
        it "filters in" do
          get :index, params: { year: 3020 }
          expect(assigns(:clients)).to eq [return_3020.client]
        end
      end

      context "filtering by unassigned" do
        let!(:unassigned) { create :tax_return, year: 2012, assigned_user: nil, client: assigned_to_me, status: "intake_open" }
        it "filters in" do
          get :index, params: { unassigned: true }
          expect(assigns(:clients)).to include unassigned.client
        end
      end

      context "filtering by needs response" do
        let!(:needs_response) { create :client, response_needed_since: DateTime.now, vita_partner: user.vita_partner, tax_returns: [(create :tax_return, assigned_user: user)] }
        it "filters in" do
          get :index, params: { needs_response: true }
          expect(assigns(:clients)).to include needs_response
        end
      end

      context "filtering and sorting" do
        let!(:starts_with_a_assigned) { create :client, intake: (create :intake, preferred_name: "Aardvark Alan"), vita_partner: user.vita_partner, tax_returns: [(create :tax_return, status: "intake_in_progress", assigned_user: user)] }

        it "preferred_name, asc" do
          get :index, params: { status: "intake_in_progress", column: "preferred_name", order: "asc" }
          expect(assigns(:clients)).to eq [starts_with_a_assigned, assigned_to_me]
        end

        it "preferred_name, desc" do
          get :index, params: { status: "intake_in_progress", column: "preferred_name", order: "desc" }
          expect(assigns(:clients)).to eq [assigned_to_me, starts_with_a_assigned]
        end
      end
    end
  end
end