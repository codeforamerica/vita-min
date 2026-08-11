require "rails_helper"

describe Portal::SettingsController do
  let(:intake) do
    build :intake,
          email_address: "exampleton@example.com",
          email_notification_opt_in: "yes",
          phone_number: "+15105551234",
          bank_account_type: "checking",
          bank_account_number: "123456789"
  end
  let(:client) { create :client, intake: intake }

  describe "#show" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :show

    context "as an authenticated client" do
      before do
        sign_in client, scope: :client
      end

      it "renders the show template and assigns the current intake" do
        get :show

        expect(response).to render_template :show
        expect(assigns(:intake)).to eq client.intake
      end

      context "when the intake has no email or phone number" do
        render_views

        let(:intake) { build :intake, email_address: nil, phone_number: nil }

        it "shows the 'not provided' fallbacks instead of the values" do
          get :show

          expect(response.body).to include "Email not provided"
          expect(response.body).to include "Phone number not provided"
        end
      end
    end
  end
end
