require 'rails_helper'

describe Hub::MetricsController do
  describe '#index' do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    let(:sla_service_double) { double }
    let(:vita_partner_1) { create :vita_partner, name: "Vita Partner 1" }
    let(:vita_partner_2) { create :vita_partner, name: "Vita Partner 2" }
    let(:vita_partner_3) { create :vita_partner, name: "Vita Partner 3" }
    let(:generated_at) { DateTime.new(2020, 9, 2) }
    let(:breach_threshold) { DateTime.new(2020, 8, 30) }
    let(:breach_data) {{ vita_partner_1.id => 2, vita_partner_2.id => 1} }
    before do
      allow(SLABreachService).to receive(:new).and_return(sla_service_double)
      allow(sla_service_double).to receive(:report_generated_at).and_return generated_at
      allow(sla_service_double).to receive(:breach_threshold).and_return breach_threshold
      allow(sla_service_double).to receive(:attention_needed_breach).and_return breach_data
    end
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
        expect(assigns(:attention_needed).current_as_of).to eq generated_at
        expect(assigns(:attention_needed).breach_threshold).to eq breach_threshold
        expect(assigns(:attention_needed).total_breaches).to eq 3
        expect(assigns(:attention_needed).breach_counts).to eq breach_data
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

        expect(assigns(:attention_needed).current_as_of).to eq generated_at
        expect(assigns(:attention_needed).breach_threshold).to eq breach_threshold
        expect(assigns(:attention_needed).total_breaches).to eq 2
        expect(assigns(:attention_needed).breach_counts).to eq breach_data
      end
    end
  end
end