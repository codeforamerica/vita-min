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
      let!(:client_within_sla) { create :client_with_intake_and_return, last_outgoing_interaction_at: 2.business_days.ago, vita_partner: site }
      let!(:four_day_completed_status) { create :client, intake: (create :intake), last_outgoing_interaction_at: 4.days.ago, vita_partner: site, tax_returns: [create(:tax_return, status: "file_accepted")]}
      let!(:four_day_breach_client) { create :client_with_intake_and_return, last_outgoing_interaction_at: 4.business_days.ago, vita_partner: site }
      let!(:six_day_breach_client) { create :client_with_intake_and_return, last_outgoing_interaction_at: 6.business_days.ago, vita_partner: site }
      let!(:ten_day_breach_client_done_filing) do
        create :client,
               last_outgoing_interaction_at: 10.business_days.ago,
               vita_partner: site,
               intake: build(:intake),
               tax_returns: [
                 build(:tax_return, year: 2018, status: "file_not_filing"),
                 build(:tax_return, year: 2019, status: "file_accepted"),
                 build(:tax_return, year: 2020, status: "file_mailed"),
               ]
      end
      let!(:ten_day_breach_client_half_done_filing) do
        create :client,
               last_outgoing_interaction_at: 10.business_days.ago,
               vita_partner: site,
               intake: build(:intake),
               tax_returns: [
                 build(:tax_return, year: 2018, status: "file_not_filing"),
                 build(:tax_return, year: 2019, status: "review_ready_for_call"),
               ]
      end
      before do
        sign_in user
        [client_within_sla, four_day_breach_client, six_day_breach_client].each do |client|
          client.tax_returns.update(status: "intake_ready")
        end
      end

      it "shows clients who last outgoing interaction was 3 or more business days, sorted by how long they've been waiting" do
        get :index

        expect(assigns(:clients)).to eq [ten_day_breach_client_half_done_filing, six_day_breach_client, four_day_breach_client]
      end

      context "with a sla_days param" do
        let(:params) { { sla_days: "5" } }

        it "filters the breach threshold" do
          get :index, params: params

          expect(assigns(:clients)).to eq [ten_day_breach_client_half_done_filing, six_day_breach_client]
        end
      end

      context "with an absurd param value" do
        let(:params) { { sla_days: "<script src=\"malicious.js\">" } }

        it "ignores the value and just defaults to 3 days" do
          get :index, params: params

          expect(assigns(:clients)).to eq [ten_day_breach_client_half_done_filing, six_day_breach_client, four_day_breach_client]
        end
      end
    end
  end
end
