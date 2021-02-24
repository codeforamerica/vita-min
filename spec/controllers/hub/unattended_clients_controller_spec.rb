
require "rails_helper"

RSpec.describe Hub::UnattendedClientsController, type: :controller do
  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "as an authenticated team member" do
      let(:user) { create(:team_member_user) }
      let(:site) { user.role.site }
      let!(:client_within_sla) { create :client_with_intake_and_return, first_unanswered_incoming_interaction_at: 2.business_days.ago, vita_partner: site }
      let!(:four_day_breach_client) { create :client_with_intake_and_return, first_unanswered_incoming_interaction_at: 4.business_days.ago, vita_partner: site }
      let!(:six_day_breach_client) { create :client_with_intake_and_return, first_unanswered_incoming_interaction_at: 6.business_days.ago, vita_partner: site }
      let!(:seven_day_needs_response_breach_client) do
        create(
          :client_with_intake_and_return,
          first_unanswered_incoming_interaction_at: 2.business_days.ago,
          response_needed_since: 7.business_days.ago,
          vita_partner: site,
        )
      end
      before do
        sign_in user
        [client_within_sla, four_day_breach_client, six_day_breach_client, seven_day_needs_response_breach_client].each do |client|
          client.tax_returns.update(status: "intake_ready")
        end
      end

      it "shows clients who haven't gotten a response in 3 or more business days, sorted by how long they've been waiting" do
        get :index

        expect(assigns(:clients)).to eq [six_day_breach_client, four_day_breach_client, seven_day_needs_response_breach_client]
      end

      context "when it renders" do
        render_views

        it "shows columns for response needed and response needed dates, but not updated at or consented at" do
          get :index

          header_row = Nokogiri::HTML.parse(response.body).at_css(".index-table__head")
          expect(header_row).to have_text("Waiting on hub response")
          expect(header_row).to have_text("Waiting on response")
          expect(header_row).not_to have_text("Updated at")
          expect(header_row).not_to have_text("Consented at")
        end
      end

      context "with a sla_days param" do
        let(:params) { { sla_days: "5" } }

        it "filters the breach threshold" do
          get :index, params: params

          expect(assigns(:clients)).to eq [six_day_breach_client, seven_day_needs_response_breach_client]
        end
      end

      context "with an absurd param value" do
        let(:params) { { sla_days: "<script src=\"malicious.js\">" } }

        it "ignores the value and just defaults to 3 days" do
          get :index, params: params

          expect(assigns(:clients)).to eq [six_day_breach_client, four_day_breach_client, seven_day_needs_response_breach_client]
        end
      end
    end
  end
end
