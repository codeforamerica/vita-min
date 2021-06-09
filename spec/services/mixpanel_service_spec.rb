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

      it 'behaves identically to the class version' do
        expect(MixpanelService.instance.data_from([intake]))
          .to eq(MixpanelService.data_from([intake]))
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

    describe "#send_tax_return_event" do
      let(:coalition) { create :coalition }
      let(:organization) { create :organization, name: "Parent Org", coalition: coalition }
      let(:site) { create :site, name: "Child Site", parent_organization: organization }
      let(:client) { create :client, intake: (create :intake, visitor_id: "fake_visitor_id"), vita_partner: site }
      let(:user) { create :team_member_user, site: site }

      context "when the event is triggered by a user" do
        let!(:tax_return) { create :tax_return, certification_level: "basic", client: client, status_last_changed_by: user, status: "intake_before_consent" }

        it "sends a Mixpanel event" do
          MixpanelService.send_tax_return_event(tax_return, "ready_for_prep", { additional_data: "1234"})

          expect(fake_tracker).to have_received(:track).with(
            "fake_visitor_id",
            "ready_for_prep",
            {
              year: tax_return.year.to_s,
              certification_level: tax_return.certification_level,
              is_ctc: false,
              service_type: tax_return.service_type,
              status: "intake_before_consent",
              client_organization_name: "Parent Org",
              client_organization_id: client.vita_partner.parent_organization.id,
              client_site_name: "Child Site",
              client_site_id: client.vita_partner.id,
              user_id: user.id,
              user_site_name: site.name,
              user_site_id: site.id,
              user_organization_name: organization.name,
              user_organization_id: organization.id,
              user_coalition_name: coalition.name,
              user_coalition_id: coalition.id,
              additional_data: "1234",
            }
          )
        end
      end

      context "when the event is triggered by the system" do
        let!(:tax_return) { create :tax_return, certification_level: "basic", client: client, status: "intake_before_consent" }

        it "handles the lack of a status_last_changed_by user" do
          MixpanelService.send_tax_return_event(tax_return, "ready_for_prep")

          expect(fake_tracker).to have_received(:track).with(
            "fake_visitor_id",
            "ready_for_prep",
            hash_excluding(
              {
                user_id: user.id,
                user_site_name: site.name,
                user_site_id: site.id,
                user_organization_name: organization.name,
                user_organization_id: organization.id,
                user_coalition_name: coalition.name,
                user_coalition_id: coalition.id,
              }
            )
          )
        end
      end
    end

    describe "#send_status_change_event" do
      let(:coalition) { create :coalition }
      let(:organization) { create :organization, name: "Parent Org", coalition: coalition }
      let(:site) { create :site, name: "Child Site", parent_organization: organization }
      let(:client) { create :client, intake: (create :intake, visitor_id: "fake_visitor_id"), vita_partner: site }
      let(:user) { create :team_member_user, site: site }

      context "when the event is triggered by a user" do
        let!(:tax_return) { create :tax_return, certification_level: "basic", client: client, status_last_changed_by: user, status: "intake_before_consent" }

        before do
          tax_return.status = "review_reviewing"
        end

        it "sends a status_change event" do
          MixpanelService.send_status_change_event(tax_return)

          expect(fake_tracker).to have_received(:track).with(
            "fake_visitor_id",
            "status_change",
            {
              year: tax_return.year.to_s,
              certification_level: tax_return.certification_level,
              is_ctc: false,
              service_type: tax_return.service_type,
              status: "review_reviewing",
              client_organization_name: "Parent Org",
              client_organization_id: client.vita_partner.parent_organization.id,
              client_site_name: "Child Site",
              client_site_id: client.vita_partner.id,
              user_id: user.id,
              user_site_name: site.name,
              user_site_id: site.id,
              user_organization_name: organization.name,
              user_organization_id: organization.id,
              user_coalition_name: coalition.name,
              user_coalition_id: coalition.id,
              from_status: "intake_before_consent"
            }
          )
        end
      end
    end

    describe "#send_file_rejected_event" do
      let(:coalition) { create :coalition }
      let(:organization) { create :organization, name: "Parent Org", coalition: coalition }
      let(:site) { create :site, name: "Child Site", parent_organization: organization }
      let(:client) { create :client, intake: (create :intake, visitor_id: "fake_visitor_id"), vita_partner: site }
      let(:user) { create :team_member_user, site: site }

      context "when the event is triggered by a user" do
        let(:tax_return) { create :tax_return, certification_level: "basic", client: client, status_last_changed_by: user }

        before do
          tax_return.update_column(:ready_for_prep_at, 28.hours.ago)
          tax_return.update_column(:created_at, 2.days.ago)
        end

        it "sends a file_rejected event" do
          MixpanelService.send_file_rejected_event(tax_return)

          expect(fake_tracker).to have_received(:track).with(
            "fake_visitor_id",
            "filing_rejected",
            {
              year: tax_return.year.to_s,
              certification_level: tax_return.certification_level,
              is_ctc: false,
              service_type: tax_return.service_type,
              status: tax_return.status,
              client_organization_name: "Parent Org",
              client_organization_id: client.vita_partner.parent_organization.id,
              client_site_name: "Child Site",
              client_site_id: client.vita_partner.id,
              user_id: user.id,
              user_site_name: site.name,
              user_site_id: site.id,
              user_organization_name: organization.name,
              user_organization_id: organization.id,
              user_coalition_name: coalition.name,
              user_coalition_id: coalition.id,
              days_since_ready_for_prep: 1,
              hours_since_ready_for_prep: 28,
              days_since_tax_return_created: 2,
              hours_since_tax_return_created: 48
            }
          )
        end
      end

      context "when the event is triggered by the system" do
        let(:tax_return) { create :tax_return, certification_level: "basic", client: client }

        before do
          tax_return.update_column(:ready_for_prep_at, 28.hours.ago)
          tax_return.update_column(:created_at, 2.days.ago)
        end

        it "handles the lack of a status_last_changed_by user" do
          MixpanelService.send_file_rejected_event(tax_return)

          expect(fake_tracker).to have_received(:track).with(
            "fake_visitor_id",
            "filing_rejected",
            hash_excluding(
              {
                user_id: user.id,
                user_site_name: site.name,
                user_site_id: site.id,
                user_organization_name: organization.name,
                user_organization_id: organization.id,
                user_coalition_name: coalition.name,
                user_coalition_id: coalition.id,
              }
            )
          )
        end
      end

      context "when ready_for_prep_at has not been set" do
        let(:tax_return) { create :tax_return, certification_level: "basic", client: client }

        before do
          tax_return.update_column(:created_at, 2.days.ago)
        end

        it "set days_since_ready_for_prep and hours_since_ready_for_prep to nil" do
          MixpanelService.send_file_rejected_event(tax_return)

          expect(fake_tracker).to have_received(:track).with(
            "fake_visitor_id",
            "filing_rejected",
            hash_including(
              {
                days_since_ready_for_prep: "N/A",
                hours_since_ready_for_prep: "N/A",
              }
            )
          )
        end
      end
    end

    describe "#send_file_accepted_event" do
      let(:coalition) { create :coalition }
      let(:organization) { create :organization, name: "Parent Org", coalition: coalition }
      let(:site) { create :site, name: "Child Site", parent_organization: organization }
      let(:client) { create :client, intake: (create :intake, visitor_id: "fake_visitor_id"), vita_partner: site }
      let(:user) { create :team_member_user, site: site }

      context "when the event is triggered by a user" do
        let(:tax_return) { create :tax_return, certification_level: "basic", client: client, status_last_changed_by: user }

        before do
          tax_return.update_column(:ready_for_prep_at, 28.hours.ago)
          tax_return.update_column(:created_at, 2.days.ago)
        end

        it "sends a filing_completed event" do
          MixpanelService.send_file_accepted_event(tax_return)

          expect(fake_tracker).to have_received(:track).with(
            "fake_visitor_id",
            "filing_completed",
            {
              year: tax_return.year.to_s,
              certification_level: tax_return.certification_level,
              is_ctc: false,
              service_type: tax_return.service_type,
              status: tax_return.status,
              client_organization_name: "Parent Org",
              client_organization_id: client.vita_partner.parent_organization.id,
              client_site_name: "Child Site",
              client_site_id: client.vita_partner.id,
              user_id: user.id,
              user_site_name: site.name,
              user_site_id: site.id,
              user_organization_name: organization.name,
              user_organization_id: organization.id,
              user_coalition_name: coalition.name,
              user_coalition_id: coalition.id,
              days_since_ready_for_prep: 1,
              hours_since_ready_for_prep: 28,
              days_since_tax_return_created: 2,
              hours_since_tax_return_created: 48
            }
          )
        end
      end
    end

    describe '#data_from(obj)' do
      let(:state_of_residence) { 'CA' }
      let(:vita_partner) { create(:vita_partner, name: "test_partner") }
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
          needs_help_2020: "no",
          needs_help_2019: "yes",
          needs_help_2018: "no",
          needs_help_2017: "yes",
          needs_help_2016: "unfilled",
          primary_birth_date: Date.new(1993, 3, 12),
          spouse_birth_date: Date.new(1992, 5, 3),
          vita_partner: vita_partner,
          timezone: "America/Los_Angeles",
          satisfaction_face: "neutral",
          eip_only: true,
          claimed_by_another: "yes",
          already_applied_for_stimulus: "no",
          no_ssn: "yes",
          with_general_navigator: true,
          with_incarcerated_navigator: false,
          with_limited_english_navigator: true,
          with_unhoused_navigator: false,
        )
      end

      let(:intake2) { create :intake }

      before do
        intake.dependents << create(:dependent, birth_date: Date.new(2017, 4, 21), intake: intake)
        intake.dependents << create(:dependent, birth_date: Date.new(2005, 8, 11), intake: intake)
        intake.reload
      end

      context 'when obj is an array' do
        it 'returns data for all objects in the array' do
          enumerable_data = MixpanelService.data_from([intake, intake2])
          individual_data = MixpanelService.data_from(intake).merge(MixpanelService.data_from(intake2))

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
                                           needs_help_2020: "no",
                                           needs_help_2019: "yes",
                                           needs_help_2018: "no",
                                           needs_help_2017: "yes",
                                           needs_help_2016: "unfilled",
                                           needs_help_backtaxes: "yes",
                                           vita_partner_name: vita_partner.name,
                                           triaged_from_stimulus: "no",
                                           timezone: "America/Los_Angeles",
                                           csat: "neutral",
                                           eip_only: true,
                                           claimed_by_another: "yes",
                                           already_applied_for_stimulus: "no",
                                           no_ssn: "yes",
                                           with_general_navigator: true,
                                           with_incarcerated_navigator: false,
                                           with_limited_english_navigator: true,
                                           with_unhoused_navigator: false,
                                         })
        end

        context "with no backtax help needed" do
          let(:intake) do
            build(
              :intake,
              needs_help_2020: "yes",
              needs_help_2019: "no",
              needs_help_2018: "no",
              needs_help_2017: "no",
              needs_help_2016: "no"
            )
          end

          it "sends needs_help_backtaxes = no" do
            expect(data_from_intake).to include(needs_help_backtaxes: "no")
          end
        end

        context "when the intake has a triage source from stimulus triage" do
          let(:stimulus_triage) { create(:stimulus_triage) }
          before do
            intake.update_attribute(:triage_source, stimulus_triage)
          end

          it "includes stimulus triage data" do
            expect(data_from_intake).to include(
              stimulus_triage_source: nil,
              stimulus_triage_referrer: nil,
              stimulus_triage_chose_to_file: "unfilled",
              stimulus_triage_filed_prior_years: "unfilled",
              stimulus_triage_filed_recently: "unfilled",
              stimulus_triage_need_to_correct: "unfilled",
              stimulus_triage_need_to_file: "unfilled"
                                        )
          end
        end

        context "when the intake does not have a triage source from stimulus triage" do
          it "does not includes stimulus triage data" do
            expect(data_from_intake).not_to include(
              :stimulus_triage_source,
                                              :stimulus_triage_referrer,
                                              :stimulus_triage_chose_to_file,
                                              :stimulus_triage_filed_prior_years,
                                              :stimulus_triage_filed_recently,
                                              :stimulus_triage_need_to_correct,
                                              :stimulus_triage_need_to_file
                                            )
          end
        end
      end

      context 'when obj is a TaxReturn' do
        let(:tax_return) { create :tax_return, year: "2019", certification_level: "basic", service_type: "online_intake", status: "intake_info_requested" }
        let(:data_from_intake) { MixpanelService.data_from(tax_return) }

        it 'returns relevant data' do
          expect(data_from_intake).to eq(
            {
              year: "2019",
              certification_level: "basic",
              service_type: "online_intake",
              status: "intake_info_requested",
              is_ctc: false
            }
          )
        end
      end

      context 'when obj is a User' do
        context "when the role is AdminRole" do
          let(:user) { create :admin_user }

          it 'returns just the user id' do
            expected = {
              user_id: user.id,
              user_site_name: nil,
              user_organization_name: nil,
              user_organization_id: nil,
              user_site_id: nil,
              user_coalition_name: nil,
              user_coalition_id: nil,
            }
            expect(MixpanelService.data_from(user)).to eq(expected)
          end
        end

        context "when the role is CoalitionLeadRole" do
          let(:user) { create :coalition_lead_user }

          it 'returns user and coalition data' do
            expected = {
              user_id: user.id,
              user_coalition_name: user.role.coalition.name,
              user_coalition_id: user.role.coalition.id,
              user_organization_name: nil,
              user_organization_id: nil,
              user_site_name: nil,
              user_site_id: nil,
            }
            expect(MixpanelService.data_from(user)).to eq(expected)
          end
        end

        context "when the role is OrganizationLeadRole" do
          let(:coalition) { create(:coalition) }
          let(:user) { create :organization_lead_user, organization: create(:organization, coalition: coalition) }

          it 'returns user, coalition, and organization data' do
            expected = {
              user_id: user.id,
              user_coalition_name: coalition.name,
              user_coalition_id: coalition.id,
              user_organization_name: user.role.organization.name,
              user_organization_id: user.role.organization.id,
              user_site_name: nil,
              user_site_id: nil,
            }
            expect(MixpanelService.data_from(user)).to eq(expected)
          end
        end

        context "when the role is SiteCoordinatorRole" do
          let(:coalition) { create :coalition }
          let(:organization) { create :organization, coalition: coalition }
          let(:site) { create :site, parent_organization: organization }
          let(:user) { create :site_coordinator_user, site: site }

          it 'returns all user fields' do
            expected = {
              user_id: user.id,
              user_coalition_name: coalition.name,
              user_coalition_id: coalition.id,
              user_organization_name: organization.name,
              user_organization_id: organization.id,
              user_site_name: site.name,
              user_site_id: site.id
            }
            expect(MixpanelService.data_from(user)).to eq(expected)
          end
        end

        context "when the role is TeamMemberRole" do
          let(:coalition) { create :coalition }
          let(:organization) { create :organization, coalition: coalition }
          let(:site) { create :site, parent_organization: organization }
          let(:user) { create :team_member_user, site: site }

          it 'returns all user fields' do
            expected = {
              user_id: user.id,
              user_coalition_name: coalition.name,
              user_coalition_id: coalition.id,
              user_organization_name: organization.name,
              user_organization_id: organization.id,
              user_site_name: site.name,
              user_site_id: site.id
            }
            expect(MixpanelService.data_from(user)).to eq(expected)
          end
        end
      end

      context 'when obj is a Client' do
        context 'when client.vita_partner is an organization' do
          let(:vita_partner) { create :organization }
          let(:client) { create :client, vita_partner: vita_partner }

          it 'returns client organization data' do
            expect(MixpanelService.data_from(client)).to eq(
              {
                client_organization_name: vita_partner.name,
                client_organization_id: vita_partner.id,
                client_site_name: nil,
                client_site_id: nil,
              }
            )
          end
        end

        context 'when client.vita_partner is a site' do
          let(:organization) { create :organization }
          let(:vita_partner) { create :site, parent_organization: organization}
          let(:client) { create :client, vita_partner: vita_partner }

          it 'returns client site & organization data' do
            expect(MixpanelService.data_from(client)).to eq(
              {
                client_organization_name: organization.name,
                client_organization_id: organization.id,
                client_site_name: vita_partner.name,
                client_site_id: vita_partner.id,
              }
           )
          end
        end

        context 'when the client.vita_partner is nil' do
          let(:client) { create :client, vita_partner: nil }

          it 'returns client fields as nil' do
            expect(MixpanelService.data_from(client)).to eq(
              {
                client_organization_name: nil,
                client_organization_id: nil,
                client_site_name: nil,
                client_site_id: nil,
              }
            )
          end
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
        session[:intake_id] = params[:intake_id]
        MixpanelService.send_event(event_id: '72347236', event_name: 'inst_test_event', data: {}, request: request, path_exclusions: all_identifiers)
        render plain: 'nope'
      end
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
      params = { intake_id: 9999998 }
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

    it 'strips current_intake.id from paths' do
      intake = create(:intake)
      routes.draw { get "inst_test/:intake_id/rest" => "anonymous#inst_test" }
      get :inst_test, params: { intake_id: intake.id }

      expect(fake_tracker).to have_received(:track).with(
        '72347236',
        'inst_test_event',
        hash_including(
          path: '/inst_test/***/rest',
          full_path: '/inst_test/***/rest',
        )
      )
    end
  end
end
