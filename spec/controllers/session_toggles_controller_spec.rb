require "rails_helper"

describe SessionTogglesController do
  describe "#index" do
    context "when rails environment is not production" do
      it "does not require login" do
        get :index
        expect(response.status).to eq 200
      end
    end

    context 'when rails environment is production' do
      before do
        allow(Rails.env).to receive(:test?).and_return false
        allow(Rails.env).to receive(:production?).and_return true
      end

      it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    end

    context "when rails environment is a deployed non-production environment" do
      before do
        allow(Rails.env).to receive(:test?).and_return false
      end

      context "on the GYR domain" do
        it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

        context "with a signed in user" do
          before { sign_in create(:user) }

          it "renders the page" do
            get :index
            expect(response.status).to eq 200
          end
        end
      end
    end
  end

  describe "#create" do
    context "when rails environment is a deployed non-production environment" do
      before do
        allow(Rails.env).to receive(:test?).and_return false
      end

      context "on the GYR domain" do
        let(:params) { { session_toggle: { value: "2020-01-01T00:00" } } }

        it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

        it "does not set the app time for an anonymous user" do
          post :create, params: params
          expect(session[:session_toggles]).to be_nil
        end
      end
    end
  end
end
