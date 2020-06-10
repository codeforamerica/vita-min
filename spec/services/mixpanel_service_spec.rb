require 'rails_helper'

describe MixpanelService do
  let(:fake_tracker) { double('mixpanel tracker') }
  before(:each) do
    allow(fake_tracker).to receive(:track)
    MixpanelService.instance.instance_variable_set(:@tracker, fake_tracker)
  end

  after do
    # Do nothing
  end

  context 'when called as a singleton' do
    describe '#instance' do
      it 'returns the instance' do
        expect(MixpanelService.instance).to be_a_kind_of(MixpanelService)
        expect(MixpanelService.instance).to equal(MixpanelService.instance)
      end
    end

    describe '#run' do
      let(:sent_params) {
        {
          unique_id: 'abcde',
          event_name: 'test_event',
          data: { test: 'OK' }
        }
      }
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
    let(:fake_user_agent) do
      double(
        'fake_user_agent',
        name: 'TestZilla',
        full_version: '6.6.6',
        os_name: 'BeOS',
        os_full_version: '12.3.3',
        bot?: false,
        bot_name: '',
        device_brand: 'IRIX',
        device_name: 'O2',
        device_type: 'obsolete server',
      )
    end

    before do
      allow(bare_request).to receive(:user_agent).and_return(fake_user_agent)
      allow(bare_request).to receive(:referrer).and_return("http://test-host.dev/remove-me/referred")
      allow(bare_request).to receive(:path).and_return("/remove-me/resource")
      allow(bare_request).to receive(:fullpath).and_return("/remove-me/resource?id=whatever")
    end

    describe "#strip_all_from" do
      it 'strips a list of strings from a target string' do
        expect(MixpanelService.strip_all_from('what a day', ['a', 'w']))
          .to eq('ht  dy')
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

        expect(fake_tracker).to have_received(:track).with(event_id,
                                                           event_name,
                                                           hash_including(path: "//resource",
                                                                          full_path: "//resource?id=whatever"))
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

        partner = create :vita_partner,
                          name: "test_partner",
                          zendesk_group_id: "1234567890123456"
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

      let!(:dependent_one) { create :dependent, birth_date: Date.new(2017, 4, 21), intake: intake}
      let!(:dependent_two) { create :dependent, birth_date: Date.new(2005, 8, 11), intake: intake}

      let(:ticket_status) do
        create(
          :ticket_status,
          intake_status: EitcZendeskInstance::INTAKE_STATUS_IN_REVIEW,
          return_status: EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS
        )
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

## this section tests controller-specific features of mixpanel_service
#

describe ApplicationController, type: :controller do
  let(:fake_tracker) { double('mixpanel tracker') }
  before(:each) do
    allow(fake_tracker).to receive(:track)
    MixpanelService.instance.instance_variable_set(:@tracker, fake_tracker)
  end

  describe "#send_event" do
    controller do
      def index
        MixpanelService.send_event(
          event_id: '72347234',
          event_name: 'test_event',
          data: {},
          source: self
        )
        render plain: 'nope'
      end
    end

    it 'includes controller (source) information, if present' do
      get :index

      expect(fake_tracker).to have_received(:track).with(
        '72347234',
        'test_event',
        hash_including(
          :source,
          :utm_state,
          :controller_name,
          :controller_action,
          :controller_action_name
        )
      )
    end
  end
end
