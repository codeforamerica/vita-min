require "rails_helper"

describe Hub::AutomatedMessagesController do
  describe "#index" do
    it_behaves_like :a_get_action_for_admins_only, action: :index
    before do
      DefaultErrorMessages.generate!
    end

    context "as an authenticated user" do
      before do
        sign_in create(:admin_user)
      end

      render_views

      it "successfully renders messages that are sent to client in an automated way" do
        get :index

        expect(response.body).to have_text(I18n.t("messages.successful_submission_online_intake.email.body"))
      end

      it "includes every AutomatedMessage class" do
        get :index

        shown_message_classes = assigns(:messages).map { |m| m.class.name }
        message_class_names = AutomatedMessage::AutomatedMessage.descendants.map &:name

        expect(shown_message_classes).to match_array(message_class_names)
      end
    end
  end
end
