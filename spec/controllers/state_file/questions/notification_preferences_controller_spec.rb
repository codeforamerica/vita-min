require "rails_helper"

describe StateFile::Questions::NotificationPreferencesController do
  let(:intake) { create :state_file_az_refund_intake }
  before do
    sign_in intake
  end

  describe '#edit' do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
      expect(response_html).to have_text I18n.t("state_file.questions.notification_preferences.edit.title")
    end

    context "showing existing contact info or an input" do
      it "shows the existing contact info when we have their email or phone" do
        intake.update(email_address: "actuallyadog@example.woof", phone_number: "+14153334444")
        get :edit

        expect(response_html).not_to have_css("#state_file_notification_preferences_form_email_address")
        expect(response_html).not_to have_css("#state_file_notification_preferences_form_phone_number")

        expect(response_html).to have_text I18n.t("state_file.questions.notification_preferences.edit.provided_contact", contact_info: "actuallyadog@example.woof")
        expect(response_html).to have_text I18n.t("state_file.questions.notification_preferences.edit.provided_contact", contact_info: "(415) 333-4444")
      end

      it "shows the existing contact info when we don't have their email or phone" do
        get :edit

        expect(response_html).not_to have_text I18n.t("state_file.questions.notification_preferences.edit.provided_contact", contact_info: "actuallyadog@example.woof")
        expect(response_html).not_to have_text I18n.t("state_file.questions.notification_preferences.edit.provided_contact", contact_info: "(415) 333-4444")

        expect(response_html).to have_css("#state_file_notification_preferences_form_email_address")
        expect(response_html).to have_css("#state_file_notification_preferences_form_phone_number")
      end
    end
  end
end
