require "rails_helper"

RSpec.describe Questions::PhoneNumberCanReceiveTextsController do
  render_views
  let(:sms_phone_number) { nil }
  let!(:intake) {
    create :intake,
           phone_number: "+14155551212",
           sms_phone_number: sms_phone_number,
           sms_phone_number_verified_at: DateTime.now,
           phone_number_can_receive_texts: "unfilled",
           sms_notification_opt_in: "yes",
           email_notification_opt_in: "yes"
  }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#edit" do
    it "renders the corresponding template" do
      get :edit
      expect(response).to render_template :edit
    end
  end

  describe "#update" do
    let(:can_receive_texts) { "no" }
    let(:params) { { phone_number_can_receive_texts_form: { phone_number_can_receive_texts: can_receive_texts } } }

    context "when their phone number can not receive texts" do
      it "updates phone number can receive texts to no" do
        put :update, params: params
        expect(intake.reload.phone_number_can_receive_texts).to eq "no"
        expect(intake.reload.sms_phone_number).not_to eq intake.reload.phone_number
      end

      context "when phone number and sms phone number are the same" do
        let(:sms_phone_number) { "+14155551212" }
        it "sets the sms phone number to nil" do
          put :update, params: params
          expect(intake.reload.sms_phone_number).to eq nil
          expect(intake.reload.sms_phone_number_verified_at).to eq nil
        end
      end
    end

    context "when their phone can receive texts" do
      let(:can_receive_texts) { "yes" }
      it "updates phone number can receive texts to yes and updates sms_phone_number with phone_number" do
        put :update, params: params
        expect(intake.reload.phone_number_can_receive_texts).to eq "yes"
        expect(intake.reload.sms_phone_number).to eq intake.reload.phone_number
      end
    end
  end
end

