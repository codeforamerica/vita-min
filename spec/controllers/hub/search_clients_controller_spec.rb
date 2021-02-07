require 'rails_helper'

describe Hub::SearchClientsController do
  before do
    # Do nothing
  end

  after do
    # Do nothing
  end

  context "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "when user is not an admin" do
      let(:current_user) { create :coalition_lead_user }
      before { sign_in current_user }

      it "redirects to the clients index" do
        expect(
          get :index
        ).to redirect_to hub_clients_path
      end
    end

    context "when user is an admin" do
      let(:current_user) { create :admin_user }
      before {
        sign_in current_user
        create(:client, intake: (create :intake, primary_first_name: 'Matching', primary_last_name: 'Client'), tax_returns: [(create :tax_return, status: 'prep_ready_for_prep')])
        create(:client, intake: (create :intake, primary_first_name: 'Matching', primary_last_name: 'Client'), tax_returns: [(create :tax_return, status: 'prep_ready_for_prep')])
        create(:client, intake: (create :intake, primary_first_name: 'Matching', primary_last_name: 'Client'), tax_returns: [(create :tax_return, status: 'prep_ready_for_prep')])
        create(:client, intake: (create :intake, primary_first_name: 'Matching', primary_last_name: 'Client'), tax_returns: [(create :tax_return, status: 'prep_ready_for_prep')])
      }

      it "sets the page title" do
        get :index
        expect(assigns(:page_title)).to eq "Search clients"
      end

      context "without params" do
        it "loads the page without any clients" do
          get :index
          expect(assigns(:clients)).to eq []
        end
      end

      context "with the clear param" do
        it "loads the page without any clients" do
          get :index, params: { clear: true }
          expect(assigns(:clients)).to eq []
        end
      end

      context "with sort and search params" do
        it "loads the page with matching clients" do
          get :index, params: { search: 'Matching' }
          expect(assigns(:clients)).not_to be_empty
        end
      end
    end
  end
end