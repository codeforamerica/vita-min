require "rails_helper"

RSpec.describe ApplicationController do
  let(:user_agent_string) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.360" }

  controller do
    def index
      head :ok
    end
  end

  describe "#redirect_to_getyourrefund" do
    context "with a GET request to a subdomain of VitaTaxHelp.org" do
      before do
        allow_any_instance_of(ActionController::TestRequest).to receive(:host).and_return "demo.vitataxhelp.org"
        allow_any_instance_of(ActionController::TestRequest).to receive(:original_url).and_return "https://demo.vitataxhelp.org/vita_providers?zip=94609&page=2&utf8=✓"
      end

      it "redirects to the same subdomain on GetYourRefund.org with same path and params" do
        get :index

        expect(response).to redirect_to "https://demo.getyourrefund.org/vita_providers?zip=94609&page=2&utf8=✓"
      end
    end

    context "with a request to GetYourRefund.org" do
      before do
        allow_any_instance_of(ActionController::TestRequest).to receive(:host).and_return "demo.getyourrefund.org"
        allow_any_instance_of(ActionController::TestRequest).to receive(:original_url).and_return "https://demo.getyourrefund.org/vita_providers?zip=94609&page=2&utf8=✓"
      end

      it "does not redirect" do
        get :index

        expect(response.status).to eq 200
      end
    end
  end

  describe "#include_google_analytics?" do
    it "returns false" do
      expect(subject.include_google_analytics?).to eq false
    end
  end

  describe "#set_visitor_id" do
    context "existing visitor_id" do
      context "on current_intake" do
        let(:intake) { create :intake, visitor_id: "123"}

        before do
          allow(subject).to receive(:current_intake).and_return(intake)
        end

        it "gets the visitor id from the intake and sets it in the cookies" do
          get :index

          expect(cookies[:visitor_id]).to eq "123"
        end
      end

      context "on cookie" do
        before do
          cookies[:visitor_id] = "123"
        end

        it "retains the existing visitor id" do
          get :index

          expect(cookies[:visitor_id]).to eq "123"
        end

        context "with current intake" do
          let(:intake) { create :intake }

          before do
            allow(subject).to receive(:current_intake).and_return(intake)
          end

          it "saves the visitor id to the intake" do
            get :index
            expect(intake.visitor_id).to eq "123"
          end
        end
      end

      context "on current_intake AND cookie" do
        let(:intake) { create :intake, visitor_id: "123" }

        before do
          allow(subject).to receive(:current_intake).and_return(intake)
          cookies[:visitor_id] = "456"
        end

        it "gets the visitor id from the intake and sets it in the cookie" do
          get :index

          expect(intake.visitor_id).to eq "123"
          expect(cookies[:visitor_id]).to eq "123"
        end
      end
    end

    context "no visitor id" do
      it "generates and sets a visitor id cookie" do
        get :index
        expect(cookies[:visitor_id]).to be_a String
        expect(cookies[:visitor_id]).to be_present
      end

      context "with current intake" do
        let(:intake) { create :intake }

        before do
          allow(subject).to receive(:current_intake).and_return(intake)
        end

        it "saves the visitor id to the intake" do
          get :index
          expect(intake.visitor_id).to eq cookies[:visitor_id]
        end
      end
    end
  end

  describe "#visitor_id" do
    before do
      cookies[:visitor_id] = "2"
    end

    it "returns the id from the cookies if no current intake" do
      get :index

      expect(subject.visitor_id).to eq "2"
    end

    context "with a current intake that has a visitor id" do
      let(:intake) { create :intake, visitor_id: "1" }

      before do
        allow(subject).to receive(:current_intake).and_return(intake)
      end

      it "gives the intake precedent over the cookies" do
        get :index

        expect(subject.visitor_id).to eq "1"
      end
    end
  end

  describe "#source" do
    context "with an existing source in the session" do
      before { session[:source] = "shrimps" }

      it "returns the session value" do
        get :index

        expect(subject.source).to eq "shrimps"
      end
    end

    context "with a 'source' param" do
      let(:params) do
        { source: "shromps"}
      end

      it "stores the param in the session" do
        get :index, params: params

        expect(session[:source]).to eq "shromps"
      end
    end

    context "with an 's' param" do
      let(:params) do
        { s: "shremps"}
      end

      it "stores the param in the session" do
        get :index, params: params

        expect(session[:source]).to eq "shremps"
      end
    end

    context "with an google.com referer header" do
      before { request.headers["HTTP_REFERER"] = "http://google.com/search" }

      it "stores the param in the session" do
        get :index

        expect(session[:source]).to eq "organic_google"
      end
    end
  end

  describe "#referrer" do
    context "with an existing referrer in the session" do
      before do
        session[:referrer] = "searchengine.shrimp"
        request.headers["HTTP_REFERER"] = "/previous_page"
      end

      it "does not override it" do
        get :index

        expect(subject.referrer).to eq "searchengine.shrimp"
      end
    end

    context "with no referrer in the session" do
      context "with an HTTP_REFERER header" do
        before { request.headers["HTTP_REFERER"] = "coolwebsite.horse" }

        it "sets the referrer from the headers" do
          get :index

          expect(session[:referrer]).to eq "coolwebsite.horse"
        end
      end

      context "without an HTTP_REFERER header" do
        it "sets the referrer to 'None'" do
          get :index

          expect(session[:referrer]).to eq "None"
        end
      end
    end
  end

  describe "#utm_state" do
    context "with an existing utm_state in the session" do
      before do
        session[:utm_state] = "CA"
      end

      it "does not override it" do
        get :index, params: { utm_state: "OH" }

        expect(subject.utm_state).to eq "CA"
      end
    end

    context "with no utm_state in the session" do
      context "with a utm_state param" do
        it "sets the referrer from the headers" do
          get :index, params: { utm_state: "CA" }

          expect(session[:utm_state]).to eq "CA"
        end
      end

      context "without a utm_state query param" do
        it "the utm_state remains nil" do
          get :index

          expect(session).not_to include(:utm_state)
        end
      end
    end
  end

  describe "#user_agent" do
    it "parses the user agent" do
      request.headers["HTTP_USER_AGENT"] = user_agent_string

      get :index

      expect(subject.user_agent.name).to eq "Chrome"
    end
  end

  describe "#send_mixpanel_event" do
    let(:mixpanel_spy) { spy(MixpanelService) }

    before do
      allow(MixpanelService).to receive(:instance).and_return(mixpanel_spy)
      cookies[:visitor_id] = "123"
      session[:source] = "vdss"
      session[:utm_state] = "CA"
      request.headers["HTTP_USER_AGENT"] = user_agent_string
      request.headers["HTTP_REFERER"] = "http://coolwebsite.horse/tax-help/vita"
    end

    it "sends default data using mixpanel service" do
      get :index

      subject.send_mixpanel_event(event_name: "beep", data: { sound: "boop" })
      expected_mixpanel_data = {
        sound: "boop",
        source: "vdss",
        utm_state: "CA",
        referrer: "http://coolwebsite.horse/tax-help/vita",
        referrer_domain: "coolwebsite.horse",
        full_user_agent: user_agent_string,
        browser_name: "Chrome",
        browser_full_version: "79.0.3945.117",
        browser_major_version: "79",
        os_name: "Mac",
        os_full_version: "10.15.2",
        os_major_version: "10",
        is_bot: false,
        bot_name: nil,
        device_brand: nil,
        device_name: nil,
        device_type: "desktop",
        device_browser_version: "Mac desktop Chrome 79",
        locale: "en",
        path: "/anonymous",
        full_path: "/anonymous",
        controller_name: "Anonymous",
        controller_action: "AnonymousController#index",
        controller_action_name: "index",
        sign_in_count: nil,
        current_sign_in_at: nil,
        last_sign_in_at: nil,
      }
      expect(mixpanel_spy).to have_received(:run).with(
        unique_id: "123",
        event_name: "beep",
        data: expected_mixpanel_data
      )
    end

    context "with a request from a bot" do
      let(:user_agent_string) { "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" }

      it "sends nothing to mixpanel" do
        get :index

        expect(mixpanel_spy).not_to have_received(:run)
      end
    end

    context "as a logged in user" do
      let(:user) { create :user }

      before do
        allow(subject).to receive(:current_user).and_return(user)
      end

      it "sends fields related to that user" do
        get :index

        expect(mixpanel_spy).to have_received(:run)
          .with(
            unique_id: "123",
            event_name: "page_view",
            data: hash_including(
              sign_in_count: user.sign_in_count,
              current_sign_in_at: user.current_sign_in_at,
              last_sign_in_at: user.last_sign_in_at,
            )
          )
      end
    end

    context "with a current intake" do
      let(:intake) do
        build(
          :intake,
          source: "horse-ad-campaign-26",
          referrer: "http://coolwebsite.horse/tax-help/vita",
          had_disability: "yes",
          spouse_had_disability: "no"
        )
      end
      let!(:primary_user) { create :user, intake: intake, birth_date: "1993-05-16" }
      let!(:spouse_user) { create :user, is_spouse: true, intake: intake, birth_date: "1992-11-04" }

      before do
        allow(subject).to receive(:current_intake).and_return(intake)
      end

      it "sends fields about the intake" do
        get :index

        expect(mixpanel_spy).to have_received(:run).with(
          unique_id: "123",
          event_name: "page_view",
          data: hash_including(
            intake_source: "horse-ad-campaign-26",
            intake_referrer: "http://coolwebsite.horse/tax-help/vita",
            intake_referrer_domain: "coolwebsite.horse",
            primary_filer_age_at_end_of_tax_year: "26",
            spouse_age_at_end_of_tax_year: "27",
            primary_filer_disabled: "yes",
            spouse_disabled: "no",
          )
        )
      end
    end
  end

  describe "#track_page_view" do
    before do
      allow(subject).to receive(:send_mixpanel_event)
    end

    context "with a POST request" do
      it "does not send a page view event to mixpanel" do
        post :index

        expect(subject).not_to have_received(:send_mixpanel_event)
      end
    end

    context "with a GET request" do
      it "sends a page view event to mixpanel" do
        get :index

        expect(subject).to have_received(:send_mixpanel_event).with(event_name: "page_view")
      end
    end
  end

  describe "#require_sign_in" do
    controller do
      before_action :require_sign_in

      def index
        head :ok
      end
    end

    it "adds the after_login param onto the URL" do
      get :index

      expected_path = controller.identity_questions_path(after_login: "/anonymous")
      expect(response).to redirect_to(expected_path)
    end
  end

  describe "#check_maintenance_mode" do
    controller do
      def index
        head :ok
      end
    end

    context "when not in maintenance mode" do
      it "renders successfully" do
        get :index
        expect(response).to be_successful
      end
    end

    context "when in maintenance mode" do
      before do
        ENV['MAINTENANCE_MODE'] = '1'
      end

      after do
        ENV.delete('MAINTENANCE_MODE')
      end

      it "redirects to the maintenance page" do
        get :index
        expect(response).to redirect_to(maintenance_path)
      end
    end

    context "with maintenance mode scheduled" do
      before do
        ENV['MAINTENANCE_MODE_SCHEDULED'] = '1'
      end

      after do
        ENV.delete('MAINTENANCE_MODE_SCHEDULED')
      end

      it "displays a flash message to the user" do
        get :index
        expect(flash.now[:warning]).to be_present
      end
    end
  end

  describe "#append_info_to_payload" do
    controller do
      def index
        head :ok
      end
    end

    let(:fake_payload) { {} }
    let(:intake) { nil }
    let(:user) { nil }

    before do
      allow(controller).to receive(:current_intake).and_return(intake)
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "for an anonymous user" do
      it "includes a nil user_id" do
        controller.append_info_to_payload(fake_payload)
        expect(fake_payload).to include(request_details: include(user_id: nil))
      end

      it "includes other tracking properties" do
        controller.append_info_to_payload(fake_payload)
        expect(fake_payload).to include(request_details: include(:ip, :device_type, :browser_name, :os_name, :request_id, :referrer, :visitor_id))
      end
    end

    context "for an anonymous user with an intake" do
      let(:intake) { create(:intake) }

      it "includes a nil user_id but an intake_id" do
        controller.append_info_to_payload(fake_payload)
        expect(fake_payload).to include(request_details: include(user_id: nil, intake_id: intake.id))
      end
    end

    context "for a logged in user with an intake" do
      let(:intake) { create :intake }
      let(:user) { create :user, intake: intake }

      it "appends info to payload" do
        controller.append_info_to_payload(fake_payload)
        expect(fake_payload).to include(request_details: include(user_id: user.id, intake_id: intake.id))
      end
    end
  end
end
