require 'rails_helper'

RSpec.describe CaseManagement::AssignedClientsController do
  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    it_behaves_like :a_get_action_for_beta_testers_only, action: :index
  end

  context "as an authenticated beta tester" do
    render_views
    let(:vita_partner) { create(:vita_partner) }
    let(:user) { create(:beta_tester, vita_partner: vita_partner)}

    before { sign_in user}
    let!(:assigned_to_me) { create :client, vita_partner: vita_partner, intake: (create :intake), tax_returns: [(create :tax_return, assigned_user: user)] }
    let!(:not_assigned_to_me) { create :client, vita_partner: vita_partner, intake: (create :intake), tax_returns: [(create :tax_return)] }

    it "should allow me to see only clients with tax returns assigned to me" do
      get :index
      expect(assigns(:clients)).to include assigned_to_me
      expect(assigns(:clients)).not_to include not_assigned_to_me
    end

    it "renders the clients table view" do
      get :index

      expect(response).to render_template "clients/index"
    end
  end
end