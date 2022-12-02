require 'rails_helper'

describe Ctc::Questions::ConfirmW2sController do
  describe "#update" do
    let(:intake) { create :ctc_intake, client: build(:client, tax_returns: [build(:ctc_tax_return)]) }

    before do
      sign_in intake.client
      verifier_double = instance_double(ActiveSupport::MessageVerifier)
      allow(ActiveSupport::MessageVerifier).to receive(:new).and_return(verifier_double)
      allow(verifier_double).to receive(:generate).and_return("123")
    end

    context "when the client wants to add another W2" do
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
end
