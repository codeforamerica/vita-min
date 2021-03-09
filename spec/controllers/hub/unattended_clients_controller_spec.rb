require "rails_helper"

RSpec.describe Hub::UnattendedClientsController, type: :controller do
  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    around do |example|
      Timecop.freeze(DateTime.new(2021, 3, 4, 5, 10))
      example.run
      Timecop.return
    end

    context "as an authenticated team member" do
      let(:user) { create(:team_member_user) }
      let(:site) { user.role.site }
      let!(:client_within_sla) { create :client_with_intake_and_return, response_needed_since: 2.business_days.ago, vita_partner: site }
      let!(:four_day_breach_client) { create :client_with_intake_and_return, response_needed_since: 4.business_days.ago, vita_partner: site }
      let!(:six_day_breach_client) { create :client_with_intake_and_return, response_needed_since: 6.business_days.ago, vita_partner: site }
      before do
        sign_in user
        [client_within_sla, four_day_breach_client, six_day_breach_client].each do |client|
          client.tax_returns.update(status: "intake_ready")
        end
      end

      it "shows clients who haven't gotten a response in 3 or more business days, sorted by how long they've been waiting" do
        get :index

        expect(assigns(:clients)).to eq [six_day_breach_client, four_day_breach_client]
      end

      context "with a sla_days param" do
        let(:params) { { sla_days: "5" } }

        it "filters the breach threshold" do
          get :index, params: params

          expect(assigns(:clients)).to eq [six_day_breach_client]
        end
      end

      context "with an absurd param value" do
        let(:params) { { sla_days: "<script src=\"malicious.js\">" } }

        it "ignores the value and just defaults to 3 days" do
          get :index, params: params

          expect(assigns(:clients)).to eq [six_day_breach_client, four_day_breach_client]
        end
      end
    end

    context "as an authenticated admin" do
      let(:user) { create(:admin_user) }

      before do
        sign_in user
      end

      it "shows the first_unanswered_incoming_interaction_at column" do
        get :index

        expect(assigns(:show_first_unanswered_incoming_interaction_at)).to eq true
      end
    end
  end
end
