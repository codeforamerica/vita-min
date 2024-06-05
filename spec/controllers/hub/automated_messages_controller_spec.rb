require "rails_helper"

describe Hub::AutomatedMessagesController do
  describe "#index" do
    before do
      DefaultErrorMessages.generate!
    end
    it_behaves_like :a_get_action_for_admins_only, action: :index

    context "as an authenticated user" do
      before do
        sign_in create(:admin_user)
      end

      let!(:tax_return) { create :tax_return, :intake_in_progress, year: 2021 }

      render_views

      it "successfully renders messages that are sent to client in an automated way" do
        get :index

        expect(response.body).to have_text(AutomatedMessage::SuccessfulSubmissionOnlineIntake.new.sms_body)
      end

      it "includes every AutomatedMessage class" do
        get :index

        shown_message_classes = assigns(:messages).keys
        message_class_names = (AutomatedMessage::AutomatedMessage.descendants + ["UserMailer.assignment_email", "VerificationCodeMailer.with_code", "VerificationCodeMailer.no_match_found", "DiyIntakeEmailMailer.high_support_message", "CtcSignupMailer.launch_announcement", SurveyMessages::GyrCompletionSurvey, SurveyMessages::CtcExperienceSurvey])

        expect(shown_message_classes).to match_array(message_class_names)
      end
    end
  end
end
