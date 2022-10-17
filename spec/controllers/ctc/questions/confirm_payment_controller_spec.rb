require "rails_helper"

describe Ctc::Questions::ConfirmPaymentController do
  let(:intake) { create :ctc_intake }
  let!(:tax_return) { create :tax_return, client: intake.client }

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

  describe '#do_not_file' do
    it "moves the tax return object to the 'file_not_filing' status" do
      patch :do_not_file
      expect(tax_return.reload.current_state).to eq "file_not_filing"
    end

    it "shows a flash notice alerting the client that we will not file their return and redirects to the ctc home page" do
      patch :do_not_file
      expect(flash[:notice]).to eq I18n.t('views.ctc.questions.confirm_payment.do_not_file_flash_message')
      expect(response).to redirect_to root_path
    end

    it "clears the intake_id from the current session" do
      patch :do_not_file
      expect(session[:intake_id]).to be_nil
    end
  end
end
