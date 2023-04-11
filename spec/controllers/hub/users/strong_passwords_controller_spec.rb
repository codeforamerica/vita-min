require 'rails_helper'

RSpec.describe Hub::Users::StrongPasswordsController do
  let!(:organization) { create :organization, allows_greeters: false }
  let(:hub_admin_user) { create(:user, role_type: "AdminRole", timezone: "America/Los_Angeles") }
  let(:non_hub_admin_user) { create(:user, role_type: "GreeterRole", high_quality_password_as_of: nil) }

  describe "#edit" do
    context "with a logged in user with non-admin hub access" do
      before { sign_in non_hub_admin_user }

      it "shows the form for updating the password" do
        get :edit
        expect(response).to be_ok
      end

      context "when password is already reset" do
        before do
          non_hub_admin_user.update!(high_quality_password_as_of: DateTime.now)
        end

        it "redirects to default login path" do
          get :edit
          expect(response).to redirect_to hub_assigned_clients_path
        end
      end
    end

    context "with a logged in user with admin hub access" do
      before { sign_in hub_admin_user }

      it "redirects to the expected page post-sign-in" do
        get :edit
        expect(response).to redirect_to hub_assigned_clients_path
      end
    end

    context "when no one is signed in" do
      it "redirects to the sign in page" do
        get :edit
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "#update" do
    before { sign_in non_hub_admin_user }

    context "with valid params" do
      it "updates the user's password, updates the password quality timestamp, and redirects to the hub" do
        freeze_time do
          expect {
            put :update, params: {
              user: {
                password: "vitavitavitavita2", password_confirmation: "vitavitavitavita2"
              }
            }
          }.to change { non_hub_admin_user.reload.encrypted_password }
          expect(non_hub_admin_user.valid_password?("vitavitavitavita2")).to be true
          expect(non_hub_admin_user.high_quality_password_as_of).to eq(DateTime.now)
          expect(response).to redirect_to(hub_assigned_clients_path)
        end
      end

      context "with invalid params" do
        context "with mismatch between password and password confirmation" do
          it "does not save the user and shows an error message" do
            put :update, params: {
              user: {
                password: "vitavitavitavita",
                password_confirmation: "something other than vitavitavitavita"
              }
            }
            non_hub_admin_user.reload
            expect(non_hub_admin_user.high_quality_password_as_of).to eq(nil)
            expect(non_hub_admin_user.high_quality_password_as_of).to be_nil
            expect(response).to be_ok
            expect(assigns(:user).errors[:password_confirmation]).to eq [I18n.t("errors.attributes.password.not_matching")]
          end
        end
      end
    end
  end
end
