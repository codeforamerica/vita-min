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
      let!(:client_within_sla) { create :client_with_intake_and_return, state: "intake_ready", first_unanswered_incoming_interaction_at: 2.business_days.ago, last_internal_or_outgoing_interaction_at: 11.business_days.ago, vita_partner: site }
      let!(:four_day_completed_status) { create :client_with_intake_and_return, state: "file_accepted", first_unanswered_incoming_interaction_at: 4.business_days.ago, last_internal_or_outgoing_interaction_at: 11.business_days.ago, vita_partner: site}
      let!(:four_day_breach_client) { create :client_with_intake_and_return, state: "intake_ready", first_unanswered_incoming_interaction_at: 4.business_days.ago, last_internal_or_outgoing_interaction_at: 11.business_days.ago, vita_partner: site }
      let!(:six_day_breach_client) { create :client_with_intake_and_return, state: "intake_ready", first_unanswered_incoming_interaction_at: 6.business_days.ago, last_internal_or_outgoing_interaction_at: 11.business_days.ago, vita_partner: site }
      let!(:ten_day_breach_client_done_filing) do
        create :client,
               first_unanswered_incoming_interaction_at: 10.business_days.ago,
               last_internal_or_outgoing_interaction_at: 11.business_days.ago,
               vita_partner: site,
               intake: build(:intake),
               tax_returns: [
                 build(:tax_return, :file_not_filing, year: 2018),
                 build(:tax_return, :file_accepted, year: 2019),
                 build(:tax_return, :file_mailed,  year: 2021),
               ]
      end
      let!(:ten_day_breach_client_half_done_filing) do
        create :client,
               first_unanswered_incoming_interaction_at: 10.business_days.ago,
               vita_partner: site,
               intake: build(:intake),
               tax_returns: [
                 build(:tax_return, :file_not_filing, year: 2018),
                 build(:tax_return, :review_ready_for_call, year: 2019),
               ]
      end
      before do
        sign_in user
      end

      it "shows clients whose last incoming interaction was 3 or more business days" do
        get :index
        expect(assigns(:clients)).to match_array [ten_day_breach_client_half_done_filing, six_day_breach_client, four_day_breach_client]
      end

      context "with a sla_days param" do
        let(:params) { { sla_days: "5" } }

        it "filters the breach threshold" do
          get :index, params: params

          expect(assigns(:clients)).to match_array [ten_day_breach_client_half_done_filing, six_day_breach_client]
        end
      end

      context "with an absurd param value" do
        let(:params) { { sla_days: "<script src=\"malicious.js\">" } }

        it "ignores the value and just defaults to 3 days" do
          get :index, params: params

          expect(assigns(:clients)).to match_array [ten_day_breach_client_half_done_filing, six_day_breach_client, four_day_breach_client]
        end
      end

      context "message summaries" do
        let(:fake_message_summaries) { {} }

        before do
          allow(RecentMessageSummaryService).to receive(:messages).and_return(fake_message_summaries)
        end

        it "assigns message_summaries" do
          get :index
          expect(assigns(:message_summaries)).to eq(fake_message_summaries)
          expect(RecentMessageSummaryService).to have_received(:messages).with(assigns(:clients).map(&:id))
        end
      end

      context "tax return count" do
        let!(:over_pagination_clients) { create_list :client_with_intake_and_return, 41, state: "intake_ready", first_unanswered_incoming_interaction_at: 6.business_days.ago, last_internal_or_outgoing_interaction_at: 11.business_days.ago, vita_partner: site }
        let(:params) do
          {
            page: "1"
          }
        end

        it "shows the full amount of tax returns" do
          get :index, params: params

          expect(assigns(:tax_return_count)).to eq 50
        end
      end
    end
  end
end
