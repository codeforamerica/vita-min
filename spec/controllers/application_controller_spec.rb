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

  describe "#include_analytics?" do
    it "returns false" do
      expect(subject.include_analytics?).to eq false
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

  describe "#switch_locale" do
    let(:language) { 'zz' }
    let(:available_locales) { ['zz', 'yy'] }

    before do
      @params = { things: 'stuff' }
      allow(I18n).to receive(:with_locale)
      allow(I18n).to receive(:default_locale).and_return('zz')
      allow(I18n).to receive(:available_locales).and_return(available_locales)
    end

    describe "with no preferences" do
      context "with a request to getyourrefund.org" do
        let(:available_locales) { ['en', 'es'] }
        before do
          allow_any_instance_of(ActionController::TestRequest).to receive(:domain).and_return "getyourrefund.org"
          allow(I18n).to receive(:default_locale).and_return('en')
        end

        it "defaults to english" do
          get :index

          expect(I18n).to have_received(:with_locale).with('en', any_args)
        end
      end

      context "with a request to mireembolso.org and spanish is available" do
        let(:available_locales) { ['en', 'es'] }
        before do
          allow_any_instance_of(ActionController::TestRequest).to receive(:domain).and_return "mireembolso.org"
          allow(I18n).to receive(:default_locale).and_return('en')
        end

        it "defaults to Spanish" do
          get :index

          expect(I18n).to have_received(:with_locale).with('es', any_args)
        end
      end

      context "with a request to mireembolso.org and spanish is unavailable" do
        let(:available_locales) { ['en', 'zz'] }
        before do
          allow_any_instance_of(ActionController::TestRequest).to receive(:domain).and_return "mireembolso.org"
          allow(I18n).to receive(:default_locale).and_return('en')
        end

        it "defaults to English" do
          get :index

          expect(I18n).to have_received(:with_locale).with('en', any_args)
        end
      end
    end

    describe "with language headers" do
      before { request.headers['HTTP_ACCEPT_LANGUAGE'] = language }

      context "indicated language is unavailable" do
        let(:language) { 'xx' }

        it "defers to the default locale" do
          get :index

          expect(I18n).to have_received(:with_locale).with('zz', any_args)
        end
      end

      context "indicated language is available" do
        let(:language) { 'yy' }

        it "uses the indicated language" do
          get :index

          expect(I18n).to have_received(:with_locale).with('yy', any_args)
        end
      end

      context "with a request to mireembolso.org and Spanish is available" do
        let(:available_locales) { ['zz', 'yy', 'es'] }
        let(:language) { 'yy' }
        before do
          allow_any_instance_of(ActionController::TestRequest).to receive(:domain).and_return "mireembolso.org"
        end

        it "defaults to Spanish even when a different indicated language is available" do
          get :index

          expect(I18n).to have_received(:with_locale).with('es', any_args)
        end
      end

      context "with a request to mireembolso.org and Spanish is unavailable" do
        let(:available_locales) { ['zz', 'yy'] }
        let(:language) { 'yy' }
        before do
          allow_any_instance_of(ActionController::TestRequest).to receive(:domain).and_return "mireembolso.org"
        end

        it "uses the indicated language" do
          get :index

          expect(I18n).to have_received(:with_locale).with('yy', any_args)
        end
      end

      context "and a :locale param" do
        before { @params.merge!({ locale: locale }) }
        let(:locale) { 'yy' }

        context "that does exist" do
          it "uses the :locale param" do
            get :index, params: @params

            expect(I18n).to have_received(:with_locale).with('yy', any_args)
          end
        end

        context "that doesn't exist" do
          let(:available_locales) { ['en', 'es'] }
          before do
            allow(I18n).to receive(:with_locale).and_call_original
            allow(I18n).to receive(:default_locale).and_return('en')
            request.headers['HTTP_ACCEPT_LANGUAGE'] = nil
          end

          let(:locale) { 'xx' }

          it "doesn't explode" do
            expect {
              get :index, params: @params
            }.not_to raise_error
          end
        end
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

      context "when the param is very long" do
        let(:params) do
          { source: ("shromps" * 200)}
        end

        it "truncates it" do
          get :index, params: params

          expect(session[:source]).to eq ("shromps" * 14 + "sh")
        end
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

  describe "#open_for_intake?" do
    context "when the cookie intake_open value is set" do
      before { request.cookies[:intake_open] = { value: DateTime.current } }

      it "returns true" do
        expect(subject.open_for_intake?).to eq true
      end
    end

    context "when the cookie intake_open value is not set" do
      it "returns true" do
        expect(subject.open_for_intake?).to eq true
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

      context "with a very long HTTP_REFERER header" do
        before { request.headers["HTTP_REFERER"] = ('!' * 9001) }

        it "sets the referrer to a truncated version" do
          get :index

          expect(session[:referrer]).to eq ('!' * 200)
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

      context "with a very long utm_state param" do
        it "truncates to two characters" do
          get :index, params: { utm_state: ("!" * 9001) }

          expect(session[:utm_state]).to eq "!" * 50
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
        controller_action_name: "index"
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

    context "with a current intake" do
      let(:intake) do
        build(
          :intake,
          source: "horse-ad-campaign-26",
          referrer: "http://coolwebsite.horse/tax-help/vita",
          had_disability: "yes",
          spouse_had_disability: "no",
          primary_birth_date: Date.new(1993, 5, 16),
          spouse_birth_date: Date.new(1992, 11, 4),
          visitor_id: "current_intake_visitor_id"
        )
      end

      before do
        allow(subject).to receive(:current_intake).and_return(intake)
      end

      it "sends fields about the intake" do
        get :index

        expect(mixpanel_spy).to have_received(:run).with(
          unique_id: "current_intake_visitor_id",
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

    context "with a new locale" do
      it "sends the new locale" do
        get :index, params: { locale: 'es' }

        expect(mixpanel_spy).to have_received(:run).with(
            unique_id: "123",
            event_name: "page_view",
            data: hash_including(locale: "es")
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

  describe 'special modes' do
    controller do
      def index
        head :ok
      end
    end

    shared_examples 'render special pages' do |env_flag, page_path|
      context "when not #{env_flag} mode" do
        it 'renders successfully' do
          get :index
          expect(response).to be_successful
        end
      end

      context "when in #{env_flag} mode" do
        before do
          ENV[env_flag] = '1'
        end

        after do
          ENV.delete(env_flag)
        end

        it "redirects to the #{page_path}" do
          get :index, params: { locale: 'en' }
          expect(response).to redirect_to(page_path)
        end
      end
    end

    it_behaves_like 'render special pages', 'MAINTENANCE_MODE', '/en/maintenance'
  end

  describe '#check_maintenance_mode' do
    controller do
      def index
        head :ok
      end
    end

    context 'with maintenance mode scheduled' do
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
    let(:diy_intake) { nil }

    before do
      allow(controller).to receive(:current_intake).and_return(intake)
    end

    context "for any user" do
      it "includes other tracking properties" do
        controller.append_info_to_payload(fake_payload)
        expect(fake_payload).to include(request_details: include(:ip, :device_type, :browser_name, :os_name, :request_id, :referrer, :visitor_id))
      end
    end

    context "for a user with an intake" do
      let(:intake) { create(:intake) }

      it "includes an intake_id" do
        controller.append_info_to_payload(fake_payload)
        expect(fake_payload).to include(request_details: include(intake_id: intake.id))
      end
    end

    context "for a user with a stimulus_triage" do
      let(:stimulus_triage) { create(:stimulus_triage) }

      it "includes a stimulus_triage_id" do
        allow(controller).to receive(:current_stimulus_triage).and_return(stimulus_triage)
        controller.append_info_to_payload(fake_payload)
        expect(fake_payload)
          .to include(request_details: include(stimulus_triage_id: stimulus_triage.id))
      end
    end
  end

  describe "#set_time_zone" do
    controller do
      def index
        head :ok
      end
    end

    context "with a signed in user" do
      let(:user) { create :user }
      before do
        allow(Time).to receive(:use_zone)
        sign_in user
      end
      it "should call set_time_zone around methods" do
        get :index
        expect(Time).to have_received(:use_zone).with(user.timezone)
      end
    end

    context "when a user is not signed in" do
      before do
        allow(Time).to receive(:use_zone)
      end
      it "does not call set_time_zone around methods" do
        get :index
        expect(Time).not_to have_received(:use_zone)
      end
    end
  end

  describe "#open_for_intake?" do
    context "when session key for intake is true" do
      before do
        request.cookies[:intake_open] = { value: DateTime.current }
      end
      it "is true" do
        expect(subject.open_for_intake?).to eq true
      end
    end

    context "when session key for intake is not set" do
      it "is true" do
        expect(subject.open_for_intake?).to eq true
      end
    end

    context "when session key for intake is false" do
      before do
        request.cookies[:intake_open] = false
      end
      it "is true" do
        expect(subject.open_for_intake?).to eq true
      end
    end
  end

  describe '#show_offseason_banner?' do
    context "when open for intake" do
      before do
        allow(subject).to receive(:open_for_intake?).and_return true
      end

      it "is false" do
        expect(subject.show_offseason_banner?).to be false
      end
    end

    context "when it is a hub path or controller method" do
      controller(Hub::UsersController) do
        def hub_path; end
      end
      it "is false" do
        expect(subject.show_offseason_banner?).to be false
      end
    end

    context "when not open for intake and not a hub path" do
      before do
        allow(subject).to receive(:open_for_intake?).and_return false
      end

      it "is true" do
        expect(subject.show_offseason_banner?).to be true
      end
    end
  end

  describe "#set_sentry_context" do
    context "user context" do
      let(:intake) { create :intake }
      before do
        allow(subject).to receive(:current_intake).and_return(intake)
        allow(Raven).to receive(:user_context)
      end

      it "informs Sentry that the intake ID is part of the user identity" do
        subject.set_sentry_context
        expect(Raven).to have_received(:user_context).with hash_including(intake_id: intake.id)
      end
    end

    context "extra context" do
      let(:visitor_id) { "visitor_id" }
      let(:user_agent) { instance_double(DeviceDetector, bot?: true) }
      let(:current_user) { instance_double(User, id: 3) }
      let(:current_client) { instance_double(Client, id: 4) }
      let(:request) { instance_double(ActionDispatch::Request, request_id: 5) }

      before do
        allow(subject).to receive(:user_agent).and_return(user_agent)
        allow(subject).to receive(:visitor_id).and_return(visitor_id)
        allow(subject).to receive(:current_user).and_return(current_user)
        allow(subject).to receive(:current_client).and_return(current_client)
        allow(current_client).to receive(:intake)
        allow(subject).to receive(:request).and_return(request)
        allow(Raven).to receive(:extra_context)
      end

      it "passes visitor ID, bot status, request ID, current user ID, and current client ID to Sentry" do
        subject.set_sentry_context
        expect(Raven).to have_received(:extra_context).with(hash_including(visitor_id: visitor_id))
        expect(Raven).to have_received(:extra_context).with(hash_including(is_bot: true))
        expect(Raven).to have_received(:extra_context).with(hash_including(user_id: 3))
        expect(Raven).to have_received(:extra_context).with(hash_including(client_id: 4))
        expect(Raven).to have_received(:extra_context).with(hash_including(request_id: 5))
      end
    end
  end
end
