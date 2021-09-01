require "rails_helper"

describe Ctc::Questions::ConfirmPaymentController do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
    allow(MixpanelService).to receive(:send_event)
  end

  describe '#edit' do
    it "renders edit template and sends a mixpanel event" do
      get :edit, params: {}
      expect(response).to render_template :edit
      expect(MixpanelService).to have_received(:send_event).with(hash_including(event_name: "ctc_efile_estimated_payments"))
    end
  end
end