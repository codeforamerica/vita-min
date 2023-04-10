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
      context "when they have a weak password" do
        context "when they are not an admin" do
          before do
            sign_in create(:team_member_user, :with_weak_password)
          end

          it "redirects to change their weak password" do
            get :index
            expect(response).to redirect_to Hub::Users::StrongPasswordsController.to_path_helper
          end
        end

        context "when they are an admin" do
          before do
            sign_in create(:admin_user, :with_weak_password)
          end

          it "does not redirect" do
            get :index
            expect(response).to be_ok
          end
        end
      end

      context "when they have a strong password" do
        before do
          sign_in create(:team_member_user)
        end

        it "does not redirect" do
          get :index
          expect(response).to be_ok
        end
      end

      context "when no user is logged in" do
        it "redirects to the sign in page" do
          get :index
          expect(response).to redirect_to new_user_session_path
        end
      end
    end
  end
end