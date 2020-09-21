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
        expect(new_user_form).to have_content "Después de 5 intentos de inicio de sesión, las cuentas se bloquean durante 30 minutos."
      end
    end
  end
end
