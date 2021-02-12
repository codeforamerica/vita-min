require 'rails_helper'

describe Hub::MetricsController do
  describe '#index' do
    let(:sla_service_double) { instance_double(SLABreachService) }
    let(:vita_partner_1) { create :vita_partner, name: "Vita Partner 1" }
    let(:vita_partner_2) { create :vita_partner, name: "Vita Partner 2" }
    let(:vita_partner_3) { create :vita_partner, name: "Vita Partner 3" }
    let(:generated_at) { DateTime.new(2020, 9, 2) }
    let(:breach_threshold_date) { DateTime.new(2020, 8, 30) }
    let(:breach_data) { { vita_partner_1.id => 2, vita_partner_2.id => 1} }

    before do
      allow(SLABreachService).to receive(:new).and_return(sla_service_double)
      allow(sla_service_double).to receive(:report_generated_at).and_return generated_at
      allow(sla_service_double).to receive(:breach_threshold_date).and_return breach_threshold_date
      allow(sla_service_double).to receive(:attention_needed_breaches).and_return breach_data
      allow(sla_service_double).to receive(:outgoing_communication_breaches).and_return breach_data
      allow(sla_service_double).to receive(:outgoing_interaction_breaches).and_return breach_data
    end

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context 'when authenticated as an admin' do
      before do
        sign_in (create :admin_user)
      end

      it 'renders the metrics index template' do
        get :index
        expect(response).to render_template :index
      end

      it 'makes appropriate data accessible to the template' do
        get :index
        expect(assigns(:breach_data).current_as_of).to eq generated_at
        expect(assigns(:breach_data).breach_threshold_date).to eq breach_threshold_date
        expect(assigns(:breach_data).total_breaches).to eq 3
        expect(assigns(:breach_data).breach_counts).to eq breach_data
      end
    end

    context 'when authenticated as an org lead for vita partner 1' do
      before { sign_in (create :organization_lead_user, organization: vita_partner_1) }

      it 'renders the metrics index template' do
        get :index
        expect(response).to render_template :index
      end

      it 'makes the appropriate data accessible to the template' do
        get :index

        expect(assigns(:breach_data).current_as_of).to eq generated_at
        expect(assigns(:breach_data).breach_threshold_date).to eq breach_threshold_date
        expect(assigns(:breach_data).attention_needed_breaches_by_vita_partner).to eq breach_data
        expect(assigns(:breach_data).communication_breaches_by_vita_partner).to eq breach_data
        expect(assigns(:breach_data).interaction_breachs_by_vita_partner).to eq breach_data
        expect(assigns(:breach_data).attention_needed_breach_count).to eq 2
        expect(assigns(:breach_data).communication_breach_count).to eq 2
        expect(assigns(:breach_data).interaction_breach_count).to eq 2
      end
    end
  end
end