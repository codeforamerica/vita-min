require "rails_helper"

RSpec.describe Users::SessionsController do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#new" do
    context "when the locale is not english and an invalid login alert is added by warden and the devise failure app" do
      render_views

      let(:locale_params) { { locale: "es" } }
      let(:fake_flash) { { alert: "Invalid email or password" } }
      before do
        allow(subject).to receive(:flash).and_return(fake_flash)
      end

      it "displays the properly translated error message as a form validation error and not as a flash message" do
        get :new, params: locale_params

        devise_failure_alert = Nokogiri::HTML.fragment(response.body).at_css(".flash--alert ~ .flash--alert")
        expect(devise_failure_alert).to be_nil
        expect(response.body).not_to have_content "Invalid email or password"

        new_user_form = Nokogiri::HTML.fragment(response.body).at_css("form#new_user")
        expect(new_user_form).to have_content "Correo o contraseña incorrectos."
        expect(new_user_form).to have_content "Después de 5 intentos de inicio de sesión, las cuentas se bloquean."
      end
    end
  end

  describe "#create" do
    let(:email) { "user@example.com" }
    let!(:user) { create :user, email: email, password: "vitavitavitavita", should_enforce_strong_password: false }
    let(:params) do
      {
        user: {
          email: email,
          password: "vitavitavitavita"
        }
      }
    end

    it "signs in the user and redirects to hub root path by default" do
      expect do
        post :create, params: params
      end.to change(subject, :current_user).from(nil).to(user)

      expect(response).to redirect_to hub_assigned_clients_path
    end

    describe "password strength checks" do
      context "with a non-admin user" do
        let(:user) { build :organization_lead_user, password: password, should_enforce_strong_password: false, high_quality_password_as_of: nil }

        context "when the password is strong" do
          let(:password) { "UseAStronger!Password2023" }
          before { user.save }

          it "signs in the user, starts enforcing password strength, and stores that the password is strong" do
            freeze_time do
              post :create, params: { user: { email: user.email, password: user.password } }
              expect(subject.current_user).to eq(user)
              user.reload
              expect(user.high_quality_password_as_of).to eq(DateTime.now)
              expect(user.should_enforce_strong_password).to eq(true)
            end
          end
        end

        context "when the password is weak" do
          let(:password) { "password" }
          before { user.save(validate: false) }

          it "signs in the user, starts enforcing password strength, and does not store that the password is strong" do
            post :create, params: { user: { email: user.email, password: user.password } }
            expect(subject.current_user).to eq(user)
            user.reload
            expect(user.high_quality_password_as_of).to eq(nil)
            expect(user.should_enforce_strong_password).to eq(true)
          end
        end
      end

      context "with an admin user" do
        context "with any password, even a weak one" do
          let(:user) { create :admin_user, :with_weak_password, should_enforce_strong_password: false }

          it "allows sign-in and does not update password strength columns" do
            post :create, params: { user: { email: user.email, password: user.password } }
            expect(subject.current_user).to eq(user)
            user.reload
            expect(user.high_quality_password_as_of).to eq(nil)
            expect(user.should_enforce_strong_password).to eq(false)
          end
        end
      end
    end

    context "with 'after_login_path' set in the session" do
      before { session[:after_login_path] = hub_clients_path }

      it "redirects to 'after_login_path'" do
        post :create, params: params

        expect(response).to redirect_to hub_clients_path
      end
    end

    context "when a user has been suspended" do
      before { user.update!(suspended_at: DateTime.now) }

      it "raises an error from warden" do
        post :create, params: params

        expect { subject.current_user }.to raise_error(UncaughtThrowError)
      end
    end

    context "user has a codeforamerica.org email" do
      let(:email) { "user@codeforamerica.org" }

      it "doesn't log them in and flashes message to use admin sign in" do
        expect do
          post :create, params: params
        end.not_to change(subject, :current_user)

        expect(flash[:alert]).to eq I18n.t("controllers.users.sessions_controller.must_use_admin_sign_in")
      end

      context "when google_login_enabled is configured to false" do
        before do
          allow(Rails.configuration).to receive(:google_login_enabled).and_return false
        end

        it "allows them to sign in with their password" do
          expect do
            post :create, params: params
          end.to change(subject, :current_user).from(nil).to(user)
        end
      end
    end

    context "user has a getyourrefund.org email" do
      let(:email) { "user@getyourrefund.org" }

      it "doesn't log them in and flashes message to use admin sign in" do
        expect do
          post :create, params: params
        end.not_to change(subject, :current_user)

        expect(flash[:alert]).to eq I18n.t("controllers.users.sessions_controller.must_use_admin_sign_in")
      end
    end
  end

  describe "invalid params handling" do
    context "with null bytes that only a robot would send us" do
      let(:params) {
        {
          user: {
            email: "user@example.com",
            password: "invalid\0"
          }
        }
      }

      it "responds with HTTP 400" do
        post :create, params: params
        expect(response).to be_bad_request
      end
    end
  end
end
