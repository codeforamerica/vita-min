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
    context "with an end of intake toggle" do
      let(:params) { { session_toggle: { name: "end_of_intake", value: "2026-10-01T20:59" } } }

      it "saves the end of intake override without changing the app time" do
        post :create, params: params

        expect(session[:session_toggles].keys).to eq ["end_of_intake"]
        expect(session[:session_toggles]["end_of_intake"]).to eq Time.find_zone("America/Los_Angeles").parse("2026-10-01 20:59")
      end

      it "clears only the end of intake override" do
        session[:session_toggles] = { "app_time" => Time.current.iso8601, "end_of_intake" => Time.current.iso8601 }

        post :create, params: params.merge(clear: true)

        expect(session[:session_toggles].keys).to eq ["app_time"]
      end
    end

    context "with an unknown toggle name" do
      it "falls back to the app time toggle" do
        post :create, params: { session_toggle: { name: "something_else", value: "2026-10-05T12:00" } }

        expect(session[:session_toggles].keys).to eq ["app_time"]
      end
    end

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
