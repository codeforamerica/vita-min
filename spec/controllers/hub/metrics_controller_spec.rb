require 'rails_helper'

describe Hub::MetricsController do
  describe '#index' do
    let(:sla_breach_report_double) { instance_double(Report::SLABreachReport) }
    let(:vita_partner_1) { create :vita_partner, name: "Vita Partner 1" }
    let(:vita_partner_2) { create :vita_partner, name: "Vita Partner 2" }
    let(:vita_partner_3) { create :vita_partner, name: "Vita Partner 3" }
    let!(:generated_at) { DateTime.current }
    let(:breach_threshold_date) { DateTime.new(2020, 8, 30) }
    let(:breach_data) { { vita_partner_1.id => 2, vita_partner_2.id => 1} }
    let(:breach_count) { breach_data.values.inject(:+) }
    let(:report_data) do
      {
        breached_at: breach_threshold_date,
        response_needed_breaches_by_vita_partner_id: breach_data,
        communication_breaches_by_vita_partner_id: breach_data,
        last_outgoing_communication_breaches_by_vita_partner_id: breach_data,
        interaction_breaches_by_vita_partner_id: breach_data,
        response_needed_breach_count: breach_count,
        interaction_breach_count: breach_count,
        communication_breach_count: breach_count,
        last_outgoing_communication_breach_count: breach_count,
        active_sla_clients_by_vita_partner_id: breach_data,
        active_sla_clients_count: breach_count
      }
    end

    let(:current_user) { create :admin_user }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context 'when authenticated as an admin' do
      before do
        sign_in current_user
      end

      it 'renders the metrics index template' do
        get :index
        expect(response).to render_template :index
      end

      context "when a recent report already exists" do
        let!(:report) { Report::SLABreachReport.create(data: report_data, generated_at: generated_at) }

        it "does not create a new report" do
          expect {
            get :index
          }.not_to change(Report::SLABreachReport, :count)
          expect(assigns(:report)).to eq report
        end

        it 'uses the accumulated totals for all vita partners' do
          get :index
          expect(assigns(:total_breaches)[:communication]).to eq 3
          expect(assigns(:total_breaches)[:response_needed]).to eq 3
          expect(assigns(:total_breaches)[:interaction]).to eq 3
        end
      end

      context "when a recent report does not exist" do
        before do
          Report::SLABreachReport.create(data: report_data, generated_at: 30.minutes.ago)
        end

        it "creates a new report" do
          expect {
            get :index
          }.to change(Report::SLABreachReport, :count).by(1)
        end
      end
    end

    context 'when authenticated as an org lead for vita partner 1' do
      before { sign_in (create :organization_lead_user, organization: vita_partner_1) }

      it 'renders the metrics index template' do
        get :index
        expect(response).to render_template :index
      end

      context "when a recent report already exists" do
        let!(:report) { Report::SLABreachReport.create(data: report_data, generated_at: generated_at) }
        it "uses the most recent report" do
          expect {
            get :index
          }.not_to change(Report::SLABreachReport, :count)
          expect(assigns(:report)).to eq report
        end

        it 'limits the totals to those that are relevant to the vita partner the user has access to' do
          get :index

          expect(assigns(:total_breaches)[:response_needed]).to eq 2
          expect(assigns(:total_breaches)[:communication]).to eq 2
          expect(assigns(:total_breaches)[:interaction]).to eq 2
        end
      end
    end
  end
end