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
    let!(:user) { create :user, email: "user@example.com", password: "p455w0rd" }
    let(:params) do
      {
        user: {
          email: "user@example.com",
          password: "p455w0rd"
        }
      }
    end

    it "signs in the user and redirects to hub root path by default" do
      expect do
        post :create, params: params
      end.to change(subject, :current_user).from(nil).to(user)

      expect(response).to redirect_to hub_assigned_clients_path
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

        expect{ subject.current_user }.to raise_error(UncaughtThrowError)
      end
    end
  end
end
