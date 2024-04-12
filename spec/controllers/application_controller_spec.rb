require "rails_helper"

RSpec.describe ApplicationController do
  let(:user_agent_string) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.360" }

  controller do
    def index
      respond_to do |format|
        format.html { head :ok }
        format.js { head :ok }
      end
    end

    def create
      head :ok
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
        let(:intake) { create :intake, visitor_id: "123" }

        before do
          allow(subject).to receive(:current_intake).and_return(intake)
        end

        it "gets the visitor id from the intake and sets it in the cookies" do
          get :index

          expect(cookies.encrypted[:visitor_id]).to eq "123"
        end
      end

      context "on cookie" do
        before do
          cookies.encrypted[:visitor_id] = "123"
        end

        it "retains the existing visitor id" do
          get :index

          expect(cookies.encrypted[:visitor_id]).to eq "123"
        end
      end

      context "on current_intake AND cookie" do
        let(:intake) { create :intake, visitor_id: "123" }

        before do
          allow(subject).to receive(:current_intake).and_return(intake)
          cookies.encrypted[:visitor_id] = "456"
        end

        it "gets the visitor id from the intake and sets it in the cookie" do
          get :index

          expect(intake.visitor_id).to eq "123"
          expect(cookies.encrypted[:visitor_id]).to eq "123"
        end
      end
    end

    context "no visitor id" do
      it "generates and sets a visitor id cookie" do
        get :index
        expect(cookies.encrypted[:visitor_id]).to be_a String
        expect(cookies.encrypted[:visitor_id]).to be_present
      end

      context "with current intake" do
        let(:intake) { create :intake }

        before do
          allow(subject).to receive(:current_intake).and_return(intake)
        end

        it "saves the visitor id to the intake" do
          get :index
          expect(intake.visitor_id).to eq cookies.encrypted[:visitor_id]
        end
      end
    end

    context "when migrating from raw cookie to encrypted cookie" do
      context "with a valid visitor_id value in the cookie" do
        before do
          cookies[:visitor_id] = "f" * 52
          allow(SecureRandom).to receive(:hex).with(26).and_call_original
        end

        it "uses the legacy cookie value" do
          get :index
          expect(SecureRandom).not_to have_received(:hex)
          expect(cookies.encrypted[:visitor_id]).to eq("f" * 52)
        end
      end

      context "with invalid visitor_id in legacy cookie" do
        before do
          cookies[:visitor_id] = ("f" * 51) + "\xC3"
          allow(SecureRandom).to receive(:hex).with(26).and_call_original
        end

        it "generates and sets a valid visitor id cookie" do
          get :index
          expect(SecureRandom).to have_received(:hex).with(26)
          expect(cookies.encrypted[:visitor_id]).to be_a String
          expect(cookies.encrypted[:visitor_id].length).to eq(52)
          expect(cookies.encrypted[:visitor_id].last).not_to eq("\xC3")
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

          expect(I18n).to have_received(:with_locale).with('en', any_args).twice
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

          expect(I18n).to have_received(:with_locale).with('es', any_args).twice
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

          expect(I18n).to have_received(:with_locale).with('en', any_args).twice
        end
      end
    end

    describe "with language headers" do
      before { request.headers['HTTP_ACCEPT_LANGUAGE'] = language }

      context "indicated language is unavailable" do
        let(:language) { 'xx' }

        it "defers to the default locale" do
          get :index

          expect(I18n).to have_received(:with_locale).with('zz', any_args).twice
        end
      end

      context "indicated language is available" do
        let(:language) { 'yy' }

        it "uses the indicated language" do
          get :index

          expect(I18n).to have_received(:with_locale).with('yy', any_args).twice
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

          expect(I18n).to have_received(:with_locale).with('es', any_args).twice
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

          expect(I18n).to have_received(:with_locale).with('yy', any_args).twice
        end
      end

      context "and a :locale param" do
        before { @params.merge!({ locale: locale }) }
        let(:locale) { 'yy' }

        context "that does exist" do
          it "uses the :locale param" do
            get :index, params: @params

            expect(I18n).to have_received(:with_locale).with('yy', any_args).twice
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
        { source: "shromps" }
      end

      it "stores the param in the session" do
        get :index, params: params

        expect(session[:source]).to eq "shromps"
      end

      context "when the param is very long" do
        let(:params) do
          { source: ("shromps" * 200) }
        end

        it "truncates it" do
          get :index, params: params

          expect(session[:source]).to eq ("shromps" * 14 + "sh")
        end
      end

    end

    context "with an 's' param" do
      let(:params) do
        { s: "shremps" }
      end

      it "stores the param in the session" do
        get :index, params: params

        expect(session[:source]).to eq "shremps"
      end
    end
  end

  describe "#set_referrer" do
    context "with an existing referrer in the session" do
      before do
        session[:referrer] = "searchengine.shrimp"
      end

      context "if the new referer is from the same host" do
        before do
          request.headers["HTTP_REFERER"] = "http://test.host/previous_page"
        end

        it "does not override the referrer in the session" do
          get :index

          expect(subject.referrer).to eq "searchengine.shrimp"
        end
      end

      context "if the new referer is from a different host" do
        before do
          request.headers["HTTP_REFERER"] = "http://computer.example"
        end

        it "overrides it" do
          get :index

          expect(subject.referrer).to eq "http://computer.example"
        end
      end
    end

    context "with no referrer in the session" do
      context "with an HTTP_REFERER header" do
        before { request.headers["HTTP_REFERER"] = "http://coolwebsite.horse" }

        it "sets the referrer from the headers" do
          get :index

          expect(session[:referrer]).to eq "http://coolwebsite.horse"
        end
      end

      context "with a very long HTTP_REFERER header" do
        before { request.headers["HTTP_REFERER"] = 'http://' + ('!' * 9001) }

        it "sets the referrer to a truncated version" do
          get :index

          expect(session[:referrer]).to eq 'http://' + ('!' * 193)
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

  describe "#navigator" do
    context "with an existing navigator in the session" do
      before do
        session[:navigator] = "1"
      end

      it "does not override the saved value" do
        get :index, params: { navigator: "2" }

        expect(subject.navigator).to eq "1"
      end
    end

    context "with no navigator in the session" do
      context "with a navigator param" do
        it "sets the navigator from the url param" do
          get :index, params: { navigator: "1" }

          expect(session[:navigator]).to eq "1"
        end
      end

      context "with a very long navigator param" do
        it "truncates to one character" do
          get :index, params: { navigator: ("1" * 9001) }

          expect(session[:navigator]).to eq "1"
        end
      end

      context "without a navigator query param" do
        it "the navigator remains nil" do
          get :index

          expect(session).not_to include(:navigator)
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

      @mixpanel_calls = []
      allow(mixpanel_spy).to receive(:run) do |*args|
        @mixpanel_calls << args[0]
      end

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
        device_brand: "Apple",
        device_name: nil,
        device_type: "desktop",
        device_browser_version: "Mac desktop Chrome 79",
        locale: "en",
        path: "/anonymous",
        full_path: "/anonymous",
        is_ctc: false,
        domain: "test.host",
        controller_name: "Anonymous",
        controller_action: "AnonymousController#index",
        controller_action_name: "index",
      }

      expect(mixpanel_spy).to have_received(:run).with(
        distinct_id: "123",
        event_name: "beep",
        data: anything
      )
      expect(@mixpanel_calls[0][:data]).to eq(expected_mixpanel_data)
    end

    context "user is logged in" do
      let(:user_coalition) { build(:coalition, name: "Tax Universe") }
      let(:user_organization) { build(:organization, name: "Tax Collective", coalition: user_coalition) }
      let(:user_site) { create(:site, name: "Tax Partners", parent_organization: user_organization) }
      let(:user) { create(:team_member_user, sites: [user_site], current_sign_in_at: 5.minutes.ago) }

      before do
        sign_in user
      end

      it "sends user data using mixpanel service" do
        get :index

        @mixpanel_calls = []
        allow(mixpanel_spy).to receive(:run) do |*args|
          @mixpanel_calls << args[0]
        end

        subject.send_mixpanel_event(event_name: "beep", data: { sound: "boop" })

        expected_mixpanel_data = {
          user_id: user.id,
          user_site_id: user_site.id,
          user_site_name: user_site.name,
          user_organization_id: user_organization.id,
          user_organization_name: user_organization.name,
          user_coalition_id: user_coalition.id,
          user_coalition_name: user_coalition.name,
          user_login_time: a_value_within(1).of(user.current_sign_in_at),
          user_role: "TeamMemberRole"
        }
        expect(mixpanel_spy).to have_received(:run).with(
          distinct_id: "123",
          event_name: "beep",
          data: anything
        )
        expect(@mixpanel_calls[0][:data]).to include_hash(expected_mixpanel_data)
      end
    end

    context "with a request from a bot" do
      let(:user_agent_string) { "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" }

      it "sends nothing to mixpanel" do
        get :index

        expect(mixpanel_spy).not_to have_received(:run)
      end
    end

    context "with a current intake" do
      let(:primary_birth_year) { 1993 }
      let(:spouse_birth_year ) { 1992 }
      let(:intake) do
        build(
          :intake,
          source: "horse-ad-campaign-26",
          referrer: "http://coolwebsite.horse/tax-help/vita",
          had_disability: "yes",
          spouse_had_disability: "no",
          primary_birth_date: Date.new(primary_birth_year, 5, 16),
          spouse_birth_date: Date.new(spouse_birth_year, 11, 4),
          visitor_id: "current_intake_visitor_id"
        )
      end

      before do
        allow(subject).to receive(:current_intake).and_return(intake)
      end

      it "sends fields about the intake" do
        get :index

        expect(mixpanel_spy).to have_received(:run).with(
          distinct_id: "current_intake_visitor_id",
          event_name: "page_view",
          data: hash_including(
            intake_source: "horse-ad-campaign-26",
            intake_referrer: "http://coolwebsite.horse/tax-help/vita",
            intake_referrer_domain: "coolwebsite.horse",
            primary_filer_age: (MultiTenantService.new(:gyr).current_tax_year - primary_birth_year).to_s,
            spouse_age: (MultiTenantService.new(:gyr).current_tax_year - spouse_birth_year).to_s,
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
          distinct_id: "123",
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
        post :create

        expect(subject).not_to have_received(:send_mixpanel_event).with(event_name: "page_view")
      end
    end

    context "with a GET request" do
      it "sends a page view event to mixpanel" do
        get :index

        expect(subject).to have_received(:send_mixpanel_event).with(event_name: "page_view")
      end
    end
  end

  describe "#track_first_visit" do
    context "when a client is authenticated" do
      let(:client) { create(:ctc_intake, visitor_id: "visitor-123").client }

      before do
        sign_in client
        allow(subject).to receive(:send_mixpanel_event)
      end

      context "when the click event does not exist" do
        it "creates one, sets the timestamp, and sends a Mixpanel event" do
          freeze_time do
            expect { subject.track_first_visit(:w2_logout_add_later) }.to change(Analytics::Event, :count).by(1)
            record = Analytics::Event.last
            expect(record.client).to eq(client)
            expect(record.created_at).to eq(DateTime.now)
            expect(record.event_type).to eq("first_visit_w2_logout_add_later")
            expect(subject).to have_received(:send_mixpanel_event).with(event_name: "visit_w2_logout_add_later")
          end
        end
      end

      context "when the click event does exist" do
        let!(:old_event) { create(:analytics_event, client: client, event_type: "first_visit_w2_logout_add_later") }

        it "sends a Mixpanel event and does not create a new event" do
          expect { subject.track_first_visit(:w2_logout_add_later) }.to change(Analytics::Event, :count).by(0)
          expect(subject).to have_received(:send_mixpanel_event).with(event_name: "visit_w2_logout_add_later")
        end
      end
    end
  end

  describe "#track_form_submission" do
    before do
      allow(subject).to receive(:send_mixpanel_event)
    end

    context "with a POST request" do
      it "sends a form submission event to mixpanel" do
        put :create

        expect(subject).to have_received(:send_mixpanel_event).with(event_name: "form_submission")
      end
    end

    context "with a GET request" do
      it "does not send a form submission event to mixpanel" do
        get :index

        expect(subject).not_to have_received(:send_mixpanel_event).with(event_name: "form_submission")
      end
    end
  end

  describe "#set_get_started_link" do
    context "locale is en" do
      it "generates a link to the beginning of the GYR flow" do
        get :index

        expect(assigns(:get_started_link)).to eq "/en/questions/triage-personal-info"
      end
    end

    context "locale is es" do
      it "generates a link to the beginning of the GYR flow" do
        get :index, params: { locale: 'es' }

        expect(assigns(:get_started_link)).to eq "/es/questions/triage-personal-info"
      end
    end
  end

  describe 'special modes' do
    controller do
      def index
        head :ok
      end
    end

    context "when not in maintenance mode" do
      it 'renders the page' do
        get :index

        expect(response).to be_successful
      end
    end

    context "when in maintenance mode" do
      before do
        ENV["MAINTENANCE_MODE"] = '1'
      end

      after do
        ENV.delete("MAINTENANCE_MODE")
      end

      it "renders the maintenance template" do
        get :index, params: { locale: 'en' }

        expect(response.status).to eq(503)
        expect(response).to render_template 'public_pages/maintenance'
      end
    end
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

      context "when it could not be resolved due to an error" do
        before do
          allow(controller).to receive(:current_user).and_raise(ArgumentError.new())
        end

        it "marks the user as unknown" do
          controller.append_info_to_payload(fake_payload)
          expect(fake_payload).to include(request_details: include(current_user_id: nil))
        end
      end
    end

    context "for a user with an intake" do
      let(:intake) { create(:intake) }

      it "includes an intake_id" do
        controller.append_info_to_payload(fake_payload)
        expect(fake_payload).to include(request_details: include(intake_id: intake.id))
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

  describe "#open_for_gyr_intake?" do
    around do |example|
      freeze_time do
        example.run
      end
    end

    let(:past) { 1.minute.ago }
    let(:future) { Time.now + 1.minute }

    context "before the time when unique links allow intake" do
      before do
        allow(Rails.application.config).to receive(:start_of_unique_links_only_intake).and_return(future)
        allow(Rails.application.config).to receive(:start_of_open_intake).and_return(future)
        allow(Rails.application.config).to receive(:end_of_intake).and_return(future)
      end

      [
        [nil, false],
        ["yes", false],
      ].each do |cookie_value, expected|
        context "when the used_unique_link cookie is #{cookie_value.inspect}" do
          before { cookies.encrypted[:used_unique_link] = cookie_value }

          it "returns #{expected}" do
            expect(subject.open_for_gyr_intake?).to eq expected
          end
        end
      end
    end

    context "during the time when only unique links allow intake" do
      before do
        allow(Rails.application.config).to receive(:start_of_unique_links_only_intake).and_return(past)
        allow(Rails.application.config).to receive(:start_of_open_intake).and_return(future)
        allow(Rails.application.config).to receive(:end_of_intake).and_return(future)
      end

      [
        [nil, false],
        ["yes", true],
      ].each do |cookie_value, expected|
        context "when the used_unique_link cookie is #{cookie_value.inspect}" do
          before { request.cookies[:used_unique_link] = cookie_value }

          it "returns #{expected}" do
            expect(subject.open_for_gyr_intake?).to eq expected
          end
        end
      end
    end

    context "during the time when intake is open" do
      before do
        allow(Rails.application.config).to receive(:start_of_unique_links_only_intake).and_return(past)
        allow(Rails.application.config).to receive(:start_of_open_intake).and_return(past)
        allow(Rails.application.config).to receive(:end_of_intake).and_return(future)
      end

      [
        [nil, true],
        ["yes", true],
      ].each do |cookie_value, expected|
        context "when the used_unique_link cookie is #{cookie_value.inspect}" do
          before { request.cookies[:used_unique_link] = cookie_value }

          it "returns #{expected}" do
            expect(subject.open_for_gyr_intake?).to eq expected
          end
        end
      end
    end

    context "during the time when intake is closed" do
      before do
        allow(Rails.configuration).to receive(:start_of_unique_links_only_intake).and_return(past)
        allow(Rails.configuration).to receive(:start_of_open_intake).and_return(past)
        allow(Rails.configuration).to receive(:end_of_intake).and_return(past)
      end

      [
        [nil, false],
        ["yes", false],
      ].each do |cookie_value, expected|
        context "when the used_unique_link cookie is #{cookie_value.inspect}" do
          before { request.cookies[:used_unique_link] = cookie_value }

          it "returns #{expected}" do
            expect(subject.open_for_gyr_intake?).to eq expected
          end
        end
      end
    end
  end

  describe "#open_for_eitc_intake?" do
    before do
      allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return true
    end

    context "when the flipper feature is enabled" do
      before do
        Flipper.enable :eitc
      end

      it "returns true" do
        expect(subject.open_for_eitc_intake?).to eq true
      end
    end

    context "when eitc hasn't launched" do
      context "when the eitc_beta cookie is set" do
        before do
          get :index, params: { eitc_beta: "1" }
        end

        around do |example|
          Timecop.freeze(Rails.configuration.eitc_soft_launch - 1.day) do
            example.run
          end
        end

        it "returns false" do
          expect(subject.open_for_eitc_intake?).to eq false
        end
      end
    end

    context "during soft launch" do
      context "when the eitc_beta cookie is set" do
        before do
          allow(Rails.application.config).to receive(:eitc_full_launch).and_return(Rails.configuration.eitc_soft_launch + 3.days)
          get :index, params: { eitc_beta: "1" }
        end

        around do |example|
          Timecop.freeze(Rails.configuration.eitc_soft_launch + 1.day) do
            example.run
          end
        end

        it "returns true" do
          expect(subject.open_for_eitc_intake?).to eq true
        end
      end
    end

    context "during full launch" do
      around do |example|
        Timecop.freeze(Rails.configuration.eitc_full_launch + 1.day) do
          example.run
        end
      end

      it "returns true" do
        expect(subject.open_for_eitc_intake?).to eq true
      end
    end

    context "otherwise" do
      around do |example|
        Timecop.freeze(Rails.configuration.eitc_full_launch - 1.day) do
          example.run
        end
      end

      it "returns false" do
        expect(subject.open_for_eitc_intake?).to eq false
      end
    end
  end

  describe "#open_for_ctc_intake?" do
    around do |example|
      freeze_time do
        example.run
      end
    end

    let(:past) { 1.minute.ago }
    let(:future) { Time.now + 1.minute }
    before do
      allow_any_instance_of(described_class).to receive(:open_for_ctc_intake?).and_call_original
    end

    context "when intake is closed" do
      before do
        allow(Rails.application.config).to receive(:ctc_end_of_intake).and_return(past)

        allow(Rails.application.config).to receive(:ctc_soft_launch).and_return(future)
        allow(Rails.application.config).to receive(:ctc_full_launch).and_return(future)
      end

      it "returns false" do
        expect(subject.open_for_ctc_intake?).to eq false
      end
    end

    context "during full launch" do
      before do
        allow(Rails.application.config).to receive(:ctc_end_of_intake).and_return(future)
        allow(Rails.application.config).to receive(:ctc_soft_launch).and_return(past)
        allow(Rails.application.config).to receive(:ctc_full_launch).and_return(past)
      end

      it "returns true" do
        expect(subject.open_for_ctc_intake?).to eq true
      end
    end

    context "during soft launch" do
      before do
        allow(Rails.application.config).to receive(:ctc_end_of_intake).and_return(future)
        allow(Rails.application.config).to receive(:ctc_soft_launch).and_return(past)
        allow(Rails.application.config).to receive(:ctc_full_launch).and_return(future)
      end

      [
          [true, true],
          [false, false],
      ].each do |set_cookie, expected|
        context "when the ctc_beta cookie is #{set_cookie ? "set" : "not set"}" do
          before {  request.cookies[:ctc_beta] = true if set_cookie }

          it "returns #{expected}" do
            expect(subject.open_for_ctc_intake?).to eq expected
          end
        end
      end
    end
  end

  describe "#open_for_ctc_login?" do
    around do |example|
      freeze_time do
        example.run
      end
    end

    let(:past) { 1.minute.ago }
    let(:future) { Time.now + 1.minute }
    before do
      allow_any_instance_of(described_class).to receive(:open_for_ctc_login?).and_call_original
    end

    context "when login is closed" do
      before do
        allow(Rails.application.config).to receive(:ctc_end_of_login).and_return(past)

        allow(Rails.application.config).to receive(:ctc_soft_launch).and_return(future)
        allow(Rails.application.config).to receive(:ctc_full_launch).and_return(future)
      end

      it "returns false" do
        expect(subject.open_for_ctc_login?).to eq false
      end
    end

    context "during full launch" do
      before do
        allow(Rails.application.config).to receive(:ctc_end_of_login).and_return(future)
        allow(Rails.application.config).to receive(:ctc_soft_launch).and_return(past)
        allow(Rails.application.config).to receive(:ctc_full_launch).and_return(past)
      end

      it "returns true" do
        expect(subject.open_for_ctc_intake?).to eq true
      end
    end

    context "during soft launch" do
      before do
        allow(Rails.application.config).to receive(:ctc_end_of_login).and_return(future)
        allow(Rails.application.config).to receive(:ctc_soft_launch).and_return(past)
        allow(Rails.application.config).to receive(:ctc_full_launch).and_return(future)
      end

      [
          [true, true],
          [false, false],
      ].each do |set_cookie, expected|
        context "when the ctc_beta cookie is #{set_cookie ? "set" : "not set"}" do
          before {  request.cookies[:ctc_beta] = true if set_cookie }

          it "returns #{expected}" do
            expect(subject.open_for_ctc_login?).to eq expected
          end
        end
      end
    end
  end

  describe "#open_for_ctc_read_write?" do
    around do |example|
      freeze_time do
        example.run
      end
    end

    let(:past) { 1.minute.ago }
    let(:future) { Time.now + 1.minute }
    before do
      allow_any_instance_of(described_class).to receive(:open_for_ctc_read_write?).and_call_original
    end

    context "when edits are closed" do
      before do
        allow(Rails.application.config).to receive(:ctc_end_of_read_write).and_return(past)
      end

      it "returns false" do
        expect(subject.open_for_ctc_read_write?).to eq false
      end
    end

    context "when edits are open" do
      before do
        allow(Rails.application.config).to receive(:ctc_end_of_read_write).and_return(future)
      end

      it "returns true" do
        expect(subject.open_for_ctc_read_write?).to eq true
      end
    end
  end

  describe "#homepage_banner" do
    around do |example|
      freeze_time do
        example.run
      end
    end
    let(:past) { 1.minute.ago }
    let(:future) { Time.now + 1.minute }

    context "when before tax deadline and open for gyr intake" do
      before do
        allow(Rails.application.config).to receive(:tax_deadline).and_return(future)
        allow(subject).to receive(:open_for_gyr_intake?).and_return(true)
      end

      it "show document deadline warning banner" do
        expect(subject.homepage_banner).to eq :open_intake
      end
    end

    context "after tax deadline and before end-of-in-progress-intakes" do
      before do
        allow(Rails.application.config).to receive(:tax_deadline).and_return(past)
        allow(Rails.application.config).to receive(:end_of_in_progress_intake).and_return(future)
      end

      it "show off season filing banner" do
        expect(subject.homepage_banner).to eq :in_progress_intake_only
      end
    end

    context "after end of in-progress intake and before end of login" do
      before do
        allow(Rails.application.config).to receive(:end_of_intake).and_return(past)
        allow(Rails.application.config).to receive(:end_of_in_progress_intake).and_return(past)
        allow(Rails.application.config).to receive(:end_of_login).and_return(future)
      end

      it "show end of docs banner" do
        expect(subject.homepage_banner).to eq :login_only
      end
    end

    context "after end of login" do
      before do
        allow(Rails.application.config).to receive(:end_of_intake).and_return(past)
        allow(Rails.application.config).to receive(:end_of_login).and_return(past)
      end

      it "show end of login/closed banner" do
        expect(subject.homepage_banner).to eq :off_season
      end
    end
  end

  describe "#set_sentry_context" do
    context "user context" do
      let(:intake) { create :intake }
      let(:fake_sentry_scope) { double(set_user: nil, set_extras: nil) }

      before do
        allow(subject).to receive(:current_intake).and_return(intake)
        allow(Sentry).to receive(:configure_scope).and_yield(fake_sentry_scope)
      end

      it "informs Sentry that the intake ID is part of the user identity" do
        subject.set_sentry_context
        expect(fake_sentry_scope).to have_received(:set_user).with hash_including(id: intake.id)
      end
    end

    context "extra context" do
      let(:intake) { create :intake }
      let(:visitor_id) { "visitor_id" }
      let(:user_agent) { instance_double(DeviceDetector, bot?: true) }
      let(:current_user) { instance_double(User, id: 3) }
      let(:current_client) { instance_double(Client, id: 4) }
      let(:request) { instance_double(ActionDispatch::Request, request_id: 5) }
      let(:fake_sentry_scope) { double(set_user: nil, set_extras: nil) }

      before do
        allow(subject).to receive(:current_intake).and_return(intake)
        allow(subject).to receive(:user_agent).and_return(user_agent)
        allow(subject).to receive(:visitor_id).and_return(visitor_id)
        allow(subject).to receive(:current_user).and_return(current_user)
        allow(subject).to receive(:current_client).and_return(current_client)
        allow(subject).to receive(:request).and_return(request)
        allow(Sentry).to receive(:configure_scope).and_yield(fake_sentry_scope)
      end

      it "passes visitor ID, bot status, request ID, current user ID, and current client ID to Sentry" do
        subject.set_sentry_context
        expect(fake_sentry_scope).to have_received(:set_extras).with(hash_including(intake_id: intake.id))
        expect(fake_sentry_scope).to have_received(:set_extras).with(hash_including(visitor_id: visitor_id))
        expect(fake_sentry_scope).to have_received(:set_extras).with(hash_including(is_bot: true))
        expect(fake_sentry_scope).to have_received(:set_extras).with(hash_including(user_id: 3))
        expect(fake_sentry_scope).to have_received(:set_extras).with(hash_including(client_id: 4))
        expect(fake_sentry_scope).to have_received(:set_extras).with(hash_including(request_id: 5))
      end
    end
  end

  describe "#set_ctc_beta_param" do
    context "when the ctc_beta param is present and equal to 1" do
      context "when not from Ctc domain" do
        before do
          allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return false
        end

        it "does not set a cookie" do
          get :index, params: { ctc_beta: 1 }
          expect(cookies[:ctc_beta]).not_to be_present
        end
      end

      context "when on ctc domain" do
        before do
          allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return true
        end

        context "when the param value is 1" do
          it "sets the cookie value" do
            get :index, params: { ctc_beta: 1 }
            expect(cookies[:ctc_beta]).to eq "true"
          end
        end

        context "when the param value is not 1" do
          it "does not set the cookie" do
            get :index, params: { ctc_beta: 2 }
            expect(cookies[:ctc_beta]).not_to be_present
          end
        end
      end
    end
  end

  describe "#set_source" do
    context "when there is already a source in the session" do
      before do
        session[:source] = "existing_source_param"
      end

      context "when the source param in the request is nil" do
        it "does not overwrite the source in the session" do
          get :index, params: { source: nil, utm_source: nil, s: nil }

          expect(session[:source]).to eq "existing_source_param"
        end
      end

      context "when the source param in the request is not nil" do
        it "overwrites the source in the session" do
          get :index, params: { source: "new_source_param" }

          expect(session[:source]).to eq "new_source_param"
        end
      end
    end
  end

  describe "#set_collapse_main_menu" do
    context "there is no cookie" do
      it "sets collapse main menu to true" do
        subject.set_collapse_main_menu
        expect(assigns(:collapse_main_menu)).to eq false
      end
    end

    context "there is a sidebar=collapsed cookie" do
      before do
        allow(controller).to receive(:cookies).and_return({ sidebar: "collapsed" })
      end

      it "sets collapse main menu to true" do
        subject.set_collapse_main_menu
        expect(assigns(:collapse_main_menu)).to eq true
      end
    end
  end

  describe "#before_state_file_launch?" do
    context "before state file open intake" do
      let(:fake_time) { Rails.configuration.state_file_start_of_open_intake - 1.minute }

      it "returns true" do
        Timecop.freeze(fake_time) do
          expect(subject.before_state_file_launch?).to eq true
        end
      end
    end

    context "after state of open intake" do
      let(:fake_time) { Rails.configuration.state_file_start_of_open_intake + 1.minute }

      it "returns false" do
        Timecop.freeze(fake_time) do
          expect(subject.before_state_file_launch?).to eq false
        end
      end
    end

    context "after end of intake" do
      let(:fake_time) { Rails.configuration.state_file_end_of_new_intakes + 1.minute }

      it "returns false" do
        Timecop.freeze(fake_time) do
          expect(subject.before_state_file_launch?).to eq false
        end
      end
    end
  end

  context "when receiving invalid requests from robots" do
    before do
      allow(DatadogApi).to receive(:increment)
      allow_any_instance_of(ApplicationController).to receive(:protect_against_forgery?).and_return(true)
    end

    context "when receiving a request for a JS page without the Rails authenticity token" do
      it "captures the error and responds with 422" do
        get :index, format: :js
        expect(response.status).to eq 422
        expect(DatadogApi).to have_received(:increment).with("rails.invalid_cross_origin_request")
      end
    end

    context "when receiving a POST request without the Rails authenticity token" do
      it "captures the error and responds with a redirect" do
        post :index
        expect(response.status).to eq 302
        expect(DatadogApi).to have_received(:increment).with("rails.invalid_authenticity_token")
      end
    end

    context "when receiving a request with an unknown format" do
      it "responds with 404" do
        get :index, format: :text
        expect(response.status).to eq(404)
      end
    end
  end
end
