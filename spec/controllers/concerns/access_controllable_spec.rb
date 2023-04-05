require "rails_helper"

describe AccessControllable, type: :controller do
  describe "before actions" do
    controller(ApplicationController) do
      include AccessControllable

      before_action :require_sign_in

      def index
        head :ok
      end
    end

    describe "#require_sign_in" do

      context "when a non-admin is logged in" do
        let(:non_admin_user) { create(:team_member_user) }

        before do
          non_admin_user.update!(
            signed_in_after_strong_password_change: true,
            high_quality_password_as_of: nil
          )
          sign_in non_admin_user
        end

        it "redirects to change their weak password" do
          get :index
          expect(response).to redirect_to Hub::Users::StrongPasswordsController.to_path_helper
        end

        it "does not redirect if the password was already set" do
          non_admin_user.update!(high_quality_password_as_of: DateTime.now)
          get :index
          expect(response).to be_ok
        end
      end

      context "when an admin is logged in" do
        let(:admin_user) { create(:admin_user) }

        before do
          sign_in admin_user
        end

        it "does not redirect to change password" do
          get :index
          expect(response).not_to redirect_to Hub::Users::StrongPasswordsController.to_path_helper
        end
      end

      context "when no user is logged in" do
        it "does not redirect to change password" do
          get :index
          expect(response).not_to redirect_to Hub::Users::StrongPasswordsController.to_path_helper
        end
      end
    end
  end
end