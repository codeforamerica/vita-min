require "rails_helper"

describe Hub::AutomatedMessagesController do
  describe "#index" do
    it_behaves_like :a_get_action_for_admins_only, action: :index

    context "as an authenticated user" do
      before do
        sign_in create(:admin_user)
      end

      render_views

      it "successfully renders messages that are sent to client in an automated way" do
        get :index

        expect(response.body).to have_text(I18n.t("messages.successful_submission_online_intake.email_body"))
      end
    end
  end
end