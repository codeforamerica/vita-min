require 'rails_helper'

describe MixpanelService do
  let(:fake_tracker) { double('mixpanel tracker') }
  before do
    allow(fake_tracker).to receive(:track)
    MixpanelService.instance.instance_variable_set(:@tracker, fake_tracker)
  end

  after do
    MixpanelService.instance.remove_instance_variable(:@tracker)
  end

  context 'when called as a singleton' do
    describe '#instance' do
      it 'returns the instance' do
        expect(MixpanelService.instance).to be_a_kind_of(MixpanelService)
        expect(MixpanelService.instance).to equal(MixpanelService.instance)
      end
    end

    describe '#run' do
      let(:sent_params) do
        {
          unique_id: 'abcde',
          event_name: 'test_event',
          data: { test: 'OK' }
        }
      end
      let(:expected_params) { ['abcde', 'test_event', { test: 'OK' }] }

      before do
        allow(fake_tracker).to receive(:track)
      end

      it 'calls the internal tracker with expected parameters' do
        MixpanelService.instance.run(**sent_params)
        expect(fake_tracker).to have_received(:track).with(*expected_params)
      end
    end

    describe '#data_from(obj)' do
      let(:intake) { create :intake }
      let(:ticket_status) do
        create(
          :ticket_status,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_IN_REVIEW,
          return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS
        )
      end

      it 'behaves identically to the class version' do
        expect(MixpanelService.instance.data_from([intake, ticket_status]))
          .to eq(MixpanelService.data_from([intake, ticket_status]))
        expect(MixpanelService.instance.data_from([]))
          .to eq(MixpanelService.data_from([]))
        expect(MixpanelService.instance.data_from({ returns: 'empty' }))
          .to eq(MixpanelService.data_from({ returns: 'empty' }))
      end
    end
  end

  context 'when called as a service module' do
    let(:event_id) { '99991234' }
    let(:event_name) { 'test_event' }

    let(:bare_request) { ActionDispatch::Request.new({}) }

    before do
      allow(bare_request).to receive(:referrer).and_return("http://test-host.dev/remove-me/referred")
      allow(bare_request).to receive(:path).and_return("/remove-me/resource")
      allow(bare_request).to receive(:fullpath).and_return("/remove-me/resource?other_field=whatever")
    end

    describe "#strip_all_from_string" do
      it 'strips a list of strings from a target string' do
        expect(MixpanelService.strip_all_from_string('what a day', ['a', 'w']))
          .to eq('ht  dy')
      end
    end

    describe '#strip_all_from_url' do
      let(:path) { '/this/remove-me/path' }
      let(:path_plus) { '/this/remove-me/path?first=no&second=also-me' }
      let(:messy_path) { '/who/me/remove-me/path?remove=true&weird=me&dinner=meat&meet=home' }

      it 'strips a list of strings from a target url path' do
        expect(MixpanelService.strip_all_from_url(path, ['remove-me', 'immaterial']))
          .to eq('/this/***/path')
      end

      it 'strips a list of strings from a target url path and query string' do
        expect(MixpanelService.strip_all_from_url(path_plus, ['remove-me', 'also-me', 'immaterial']))
          .to eq('/this/***/path?first=no&second=***')
      end

      it 'avoids stripping subsets of urls and query strings' do
        expect(MixpanelService.strip_all_from_url(messy_path, ['me', 'meet']))
          .to eq('/who/***/remove-me/path?remove=true&weird=***&dinner=meat&***=home')
      end
    end

    describe "#send_event" do
      it 'tracks an event by name and id' do
        MixpanelService.send_event(event_id: event_id, event_name: event_name, data: {})

        expect(fake_tracker).to have_received(:track).with(event_id, event_name, any_args)
      end

      it 'includes user agent and request information, if present' do
        MixpanelService.send_event(
          event_id: event_id,
          event_name: event_name,
          data: {},
          request: bare_request
        )

        expect(fake_tracker).to have_received(:track).with(event_id, event_name, hash_including(:device_browser_version))
      end

      it 'includes locale information' do
        MixpanelService.send_event(event_id: event_id, event_name: event_name, data: {})

        expect(fake_tracker).to have_received(:track).with(event_id, event_name, hash_including(:locale))
      end

      it 'includes submitted data:' do
        MixpanelService.send_event(event_id: event_id, event_name: event_name, data: { test: "SUCCESS" })

        expect(fake_tracker).to have_received(:track).with(event_id, event_name, hash_including(test: "SUCCESS"))
      end

      it 'strips intake identifiers from paths' do
        MixpanelService.send_event(
          event_id: event_id,
          event_name: event_name,
          data: {},
          request: bare_request,
          path_exclusions: ['remove-me', 'immaterial']
        )

        expect(fake_tracker).to have_received(:track).with(
          event_id,
          event_name,
          hash_including(
            path: "/***/resource",
            full_path: "/***/resource?other_field=whatever"
          )
        )
      end

      it 'overwrites defaults with included data' do
        MixpanelService.send_event(event_id: event_id, event_name: event_name, data: { locale: "NO!" })

        expect(fake_tracker).to have_received(:track).with(event_id, event_name, hash_including(locale: "NO!"))
      end
    end

    describe '#data_from(obj)' do
      let(:state_of_residence) { 'CA' }
      let(:state) { State.find_by!(abbreviation: state_of_residence) }
      let(:vita_partner) do
        partner = state.vita_partners.first
        return partner if partner.present?

        partner = create(
          :vita_partner,
          name: "test_partner",
          zendesk_group_id: "1234567890123456"
        )
        partner.states << state
        partner
      end
      let(:intake) do
        create(
          :intake,
          had_disability: "no",
          spouse_had_disability: "yes",
          source: "beep",
          referrer: "http://boop.horse/mane",
          filing_joint: "no",
          had_wages: "yes",
          state_of_residence: state_of_residence,
          zip_code: "94609",
          intake_ticket_id: 9876,
          needs_help_2019: "yes",
          needs_help_2018: "no",
          needs_help_2017: "yes",
          needs_help_2016: "unfilled",
          primary_birth_date: Date.new(1993, 3, 12),
          spouse_birth_date: Date.new(1992, 5, 3),
          vita_partner: vita_partner
        )
      end

      let(:ticket_status) do
        create(
          :ticket_status,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_IN_REVIEW,
          return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS
        )
      end

      before do
        intake.dependents << create(:dependent, birth_date: Date.new(2017, 4, 21), intake: intake)
        intake.dependents << create(:dependent, birth_date: Date.new(2005, 8, 11), intake: intake)
        intake.reload
      end

      context 'when obj is an array' do
        it 'returns data for all objects in the array' do
          enumerable_data = MixpanelService.data_from([intake, ticket_status])
          individual_data = MixpanelService.data_from(intake).merge(MixpanelService.data_from(ticket_status))

          expect(enumerable_data).to eq(individual_data)
        end

        it 'returns an empty hash if the array is empty' do
          expect(MixpanelService.data_from([])).to eq({})
        end
      end

      context 'when obj is an unsupported object type' do
        it 'returns an empty hash' do
          data = MixpanelService.instance.data_from({ what: 'ever' })
          expect(data).to eq({})
        end
      end

      context 'when obj is an Intake' do
        let(:data_from_intake) { MixpanelService.data_from(intake) }

        it 'returns intake data for mixpanel' do
          data = MixpanelService.instance.data_from(intake)
          expect(data[:intake_source]).to eq(intake.source)
        end

        it "returns the expected hash" do
          expect(data_from_intake).to eq({
            intake_source: "beep",
            intake_referrer: "http://boop.horse/mane",
            intake_referrer_domain: "boop.horse",
            primary_filer_age_at_end_of_tax_year: "26",
            spouse_age_at_end_of_tax_year: "27",
            primary_filer_disabled: "no",
            spouse_disabled: "yes",
            had_dependents: "yes",
            number_of_dependents: "2",
            had_dependents_under_6: "yes",
            filing_joint: "no",
            had_earned_income: "yes",
            state: intake.state_of_residence,
            zip_code: "94609",
            needs_help_2019: "yes",
            needs_help_2018: "no",
            needs_help_2017: "yes",
            needs_help_2016: "unfilled",
            needs_help_backtaxes: "yes",
            zendesk_instance_domain: "eitc",
            vita_partner_group_id: vita_partner.zendesk_group_id,
            vita_partner_name: vita_partner.name,
          })
        end

        context "when the intake is anonymous" do
          let(:anonymous_intake) { create :anonymous_intake, intake_ticket_id: 9876 }

          it "returns the data for the original intake" do
            expect(MixpanelService.data_from(anonymous_intake)).to eq(data_from_intake)
          end
        end

        context "with no backtax help needed" do
          let(:intake) do
            build(
              :intake,
              needs_help_2019: "yes",
              needs_help_2018: "no",
              needs_help_2017: "no",
              needs_help_2016: "no"
            )
          end

          it "sends needs_help_backtaxes = no" do
            expect(data_from_intake).to include(needs_help_backtaxes: "no")
          end
        end
      end

      context 'when object is a TicketStatus' do
        it 'returns the expected hash' do
          expect(MixpanelService.data_from(ticket_status)).to eq({
            verified_change: true,
            ticket_id: ticket_status.intake.intake_ticket_id,
            intake_status: "In Review",
            return_status: "In Progress",
            created_at: ticket_status.created_at.utc.iso8601
          })
        end
      end
    end
  end
end

##
# this section tests controller-specific features of mixpanel_service,
# including the removal of identifying information in reports sent to mixpanel
describe ApplicationController, type: :controller do
  let(:fake_tracker) { double('mixpanel tracker') }

  before do
    allow(fake_tracker).to receive(:track)
    MixpanelService.instance.instance_variable_set(:@tracker, fake_tracker)
  end

  after do
    MixpanelService.instance.remove_instance_variable(:@tracker)
  end

  describe "#send_event" do
    controller do
      skip_after_action :track_page_view

      def index
        MixpanelService.send_event(event_id: '72347234', event_name: 'index_test_event', data: {}, source: self, request: request)
        render plain: 'nope'
      end

      def req_test
        request.env['HTTP_REFERER'] = "http://test.dev/9999998/rest"
        MixpanelService.send_event(event_id: '72347235', event_name: 'req_test_event', data: {}, request: request, path_exclusions: all_identifiers)
        render plain: 'nope'
      end

      def inst_test
        [:intake_id, :diy_intake_id].each { |k| session[k] = params[k] }
        MixpanelService.send_event(event_id: '72347236', event_name: 'inst_test_event', data: {}, request: request, path_exclusions: all_identifiers)
        render plain: 'nope'
      end

      ## mimic ZendeskController behavior
      def zendesk_ticket_id; "1212123"; end
    end

    it 'includes controller (source) information, if present' do
      get :index

      expect(fake_tracker).to have_received(:track).with(
        '72347234',
        'index_test_event',
        hash_including(
          :source,
          :utm_state,
          :controller_name,
          :controller_action,
          :controller_action_name
        )
      )
    end

    it 'strips :intake_id from paths' do
      routes.draw { get "req_test/:intake_id/rest?the-id=9999998" => "anonymous#req_test" }
      params = {intake_id: 9999998}
      get :req_test, params: params

      expect(fake_tracker).to have_received(:track).with(
        '72347235',
        'req_test_event',
        hash_including(
          path: '/req_test/***/rest?the-id=***',
          full_path: '/req_test/***/rest?the-id=***',
          referrer: 'http://test.dev/***/rest'
        )
      )
    end

    it 'strips :diy_intake_id from paths' do
      routes.draw { get "req_test/:diy_intake_id/rest?the-id=9999998" => "anonymous#req_test" }
      params = { diy_intake_id: 9999998 }
      get :req_test, params: params

      expect(fake_tracker).to have_received(:track).with(
        '72347235',
        'req_test_event',
        hash_including(
          path: '/req_test/***/rest?the-id=***',
          full_path: '/req_test/***/rest?the-id=***',
          referrer: 'http://test.dev/***/rest'
        )
      )
    end

    it 'strips :id from paths' do
      routes.draw { get "req_test/:id/rest?the-id=9999998" => "anonymous#req_test" }
      params = { id: 9999998 }
      get :req_test, params: params

      expect(fake_tracker).to have_received(:track).with(
        '72347235',
        'req_test_event',
        hash_including(
          path: '/req_test/***/rest?the-id=***',
          full_path: '/req_test/***/rest?the-id=***',
          referrer: 'http://test.dev/***/rest'
        )
      )
    end

    it 'strips :token from paths' do
      routes.draw { get "req_test/:token/rest?the-id=9999998" => "anonymous#req_test" }
      params = { token: 9999998 }
      get :req_test, params: params

      expect(fake_tracker).to have_received(:track).with(
        '72347235',
        'req_test_event',
        hash_including(
          path: '/req_test/***/rest?the-id=***',
          full_path: '/req_test/***/rest?the-id=***',
          referrer: 'http://test.dev/***/rest'
        )
      )
    end

    it 'strips :ticket_id from paths' do
      routes.draw { get "req_test/:ticket_id/rest?the-id=9999998" => "anonymous#req_test" }
      params = { ticket_id: 9999998 }
      get :req_test, params: params

      expect(fake_tracker).to have_received(:track).with(
        '72347235',
        'req_test_event',
        hash_including(
          path: '/req_test/***/rest?the-id=***',
          full_path: '/req_test/***/rest?the-id=***',
          referrer: 'http://test.dev/***/rest'
        )
      )
    end

    it 'strips zendesk_ticket_id from paths' do
      routes.draw { get "inst_test/1212123/rest?the-id=1212123" => "anonymous#inst_test" }
      get :inst_test

      expect(fake_tracker).to have_received(:track).with(
        '72347236',
        'inst_test_event',
        hash_including(
          path: '/inst_test/***/rest?the-id=***',
          full_path: '/inst_test/***/rest?the-id=***',
        )
      )
    end

    it 'strips current_intake.id and current_intake.zendesk_ticket_id from paths' do
      intake = create(:intake, intake_ticket_id: 83224)
      routes.draw { get "inst_test/:intake_id/rest?the-id=83224" => "anonymous#inst_test" }
      get :inst_test, params: { intake_id: intake.id }

      expect(fake_tracker).to have_received(:track).with(
        '72347236',
        'inst_test_event',
        hash_including(
          path: '/inst_test/***/rest?the-id=***',
          full_path: '/inst_test/***/rest?the-id=***',
        )
      )
    end

    it 'strips current_diy_intake.id and current_diy_intake.ticket_id from paths' do
      diy_intake = create(:diy_intake, ticket_id: 9999988)
      routes.draw { get "inst_test/:diy_intake_id/rest?the-id=9999988" => "anonymous#inst_test" }
      get :inst_test, params: { diy_intake_id: diy_intake.id }

      expect(fake_tracker).to have_received(:track).with(
        '72347236',
        'inst_test_event',
        hash_including(
          path: '/inst_test/***/rest?the-id=***',
          full_path: '/inst_test/***/rest?the-id=***',
        )
      )
    end
  end
end
