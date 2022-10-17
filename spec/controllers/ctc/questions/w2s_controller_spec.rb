require 'rails_helper'

describe Ctc::Questions::W2sController do
  before do
    allow(subject).to receive(:track_first_visit)
  end

  describe "#edit" do
    render_views
    let(:intake) { create :ctc_intake, client: build(:client, tax_returns: [build(:tax_return)]) }
    let!(:w2_complete) { create :w2, intake: intake, employer_name: "Code for a Meerkat", wages_amount: 1123, completed_at: Time.now }
    let!(:w2_incomplete) { create :w2, intake: intake, employer_name: "Cod for Canada", wages_amount: 2234, completed_at: nil }

    before do
      sign_in intake.client
    end

    it "shows only completed w2s on the page" do
      get :edit

      expect(response.body).to have_text("Code for a Meerkat")
      expect(response.body).to have_text("Wages: $1,123")
      expect(response.body).not_to have_text("Cod for Canada")
      expect(response.body).not_to have_text("Wages: $2,234")
    end

    it "tracks the first visit to this page" do
      get :edit
      expect(subject).to have_received(:track_first_visit).with(:w2s_list)
    end
  end

  describe "#update" do
    let(:intake) { create :ctc_intake, client: build(:client, tax_returns: [build(:tax_return)]) }

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

    before do
      allow(subject).to receive(:track_first_visit)
      allow(subject).to receive(:sign_out).and_call_original
      sign_in intake.client
    end

    it "logs the client out and sends an event to mixpanel" do
      put :add_w2_later
      expect(response).to redirect_to root_path

      expect(subject).to have_received(:track_first_visit).with(:w2_logout_add_later)
      expect(subject).to have_received(:sign_out).with(intake.client)
    end
  end
end
