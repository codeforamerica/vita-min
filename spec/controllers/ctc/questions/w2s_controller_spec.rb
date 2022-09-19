require 'rails_helper'

describe Ctc::Questions::W2sController do
  describe "#update" do
    let(:intake) { create :ctc_intake, client: build(:client, tax_returns: [build(:tax_return, year: TaxReturn.current_tax_year)]) }

    before do
      sign_in intake.client
      verifier_double = instance_double(ActiveSupport::MessageVerifier)
      allow(ActiveSupport::MessageVerifier).to receive(:new).and_return(verifier_double)
      allow(verifier_double).to receive(:generate).and_return("123")
    end

    context "when the client wants to add a W2" do
      let(:params) { { ctc_w2s_form: { had_w2s: "yes" } } }

      it "saves the answer and redirects to the first w2 page" do
        post :update, params: params

        expect(intake.reload.had_w2s_yes?).to eq true
        expect(response).to redirect_to(employee_info_questions_w2_path(id: "123"))
      end
    end

    context "when the client does not want to add a W2" do
      let(:params) { { ctc_w2s_form: { had_w2s: "no" } } }

      it "saves the answer and redirects to the first page after the w2 flow" do
        post :update, params: params

        expect(intake.reload.had_w2s_no?).to eq true
        expect(response).to redirect_to(questions_stimulus_payments_path)
      end
    end
  end

  describe "#add_w2_later" do
    let(:intake) { create :ctc_intake }
    let(:time_now) { DateTime.new(2022, 9, 19, 0, 0, 0) }

    before do
      allow(subject).to receive(:sign_out)
      allow(MixpanelService).to receive(:send_event)
      allow(MixpanelService).to receive(:data_from).with([intake.client, intake]).and_return({ fake: "data" })
      sign_in intake.client
    end

    around do |example|
      Timecop.freeze(time_now)
      example.run
      Timecop.return
    end

    it "logs the client out and sends an event to mixpanel" do
      put :add_w2_later

      expect(DateTime.parse(intake.client.analytics_journey.w2_logout_add_later)).to eq time_now
      expect(MixpanelService).to have_received(:send_event).with(hash_including(
        distinct_id: intake.visitor_id,
        event_name: "w2_logout_add_later",
        data: { fake: "data" }
      ))
      expect(subject).to have_received(:sign_out).with(intake.client)
    end
  end
end
