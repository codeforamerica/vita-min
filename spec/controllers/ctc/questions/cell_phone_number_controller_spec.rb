require "rails_helper"

describe Ctc::Questions::CellPhoneNumberController do
  let(:intake) { create :ctc_intake, sms_notification_opt_in: 'yes', locale: 'en' }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
    allow(MixpanelService).to receive(:send_event)
  end

  it_behaves_like :a_question_where_an_intake_is_required, Navigation::CtcQuestionNavigation

  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}
      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::CellPhoneNumberForm
      expect(assigns(:form).intake).to be_an_instance_of Intake::CtcIntake
    end
  end

  describe "#update" do
    let(:phone_number) { "+18324658840" }
    let(:params) do
      {
          ctc_cell_phone_number_form: {
              sms_phone_number: "(832) 465-8840",
              sms_phone_number_confirmation: "(832) 465-8840"
          }
      }
    end

    it "saves the form and redirects to the next step" do
      get :update, params: params
      intake = Intake.last
      expect(assigns(:form).intake).to be_valid
      expect(intake.sms_phone_number).to eq "+18324658840"
      expect(intake.sms_notification_opt_in_yes?).to be true
      expect(response).to redirect_to questions_phone_verification_path
    end

    it "sends an event to mixpanel without the phone number data" do
      post :update, params: params

      expect(MixpanelService).to have_received(:send_event).with(hash_including(
                                                                   event_name: "question_answered",
                                                                   data: {}
                                                                 ))
    end
  end

  describe "#after_update_success" do
    before do
      allow(ClientMessagingService).to receive(:send_system_text_message)
    end

    it "sends an opt-in sms message" do
      subject.after_update_success

      expect(ClientMessagingService).to have_received(:send_system_text_message).with(
        client: intake.client,
        body: I18n.t("messages.ctc_sms_opt_in"),
        to: intake.sms_phone_number
      )
    end
  end
end