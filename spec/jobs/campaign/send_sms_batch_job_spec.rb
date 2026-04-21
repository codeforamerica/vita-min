require "rails_helper"

describe Campaign::SendSmsBatchJob, type: :job do
  include ActiveJob::TestHelper

  subject(:perform_job) do
    described_class.new.perform(
      message_name: message_name,
      batch_size: batch_size,
      msg_delay: batch_delay,
      queue_next_batch: queue_next_batch,
      scope: scope
    )
  end

  let(:message_name) { "start_of_season_outreach" }
  let(:batch_size) { 10 }
  let(:batch_delay) { 10.seconds }
  let(:queue_next_batch) { false }
  let(:scope) { :recent_signups }

  before do
    clear_enqueued_jobs
    clear_performed_jobs

    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:cancel_campaign_sms).and_return(false)

    allow_any_instance_of(described_class).to receive(:rate_limited?).and_call_original

    allow(CampaignSms).to receive(:create_or_find_for).and_call_original
  end

  describe "#perform" do
    context "when :cancel_campaign_sms flag is enabled" do
      let!(:campaign_contact) { create(:campaign_contact, :sms_opted_in) }

      it "does nothing" do
        allow(Flipper).to receive(:enabled?).with(:cancel_campaign_sms).and_return(true)

        perform_job

        expect(CampaignSms).to_not have_received(:create_or_find_for)
      end
    end

    context "when rate limiting is detected" do
      let!(:campaign_contact) { create(:campaign_contact, :sms_opted_in) }
      let!(:error_sms) { create :campaign_sms, error_code: "63038", sent_at: 5.minutes.ago }
      let!(:error_sms_2) { create :campaign_sms, event_data: "Message rate exceeded", sent_at: 5.minutes.ago }
      let!(:sms) { create :campaign_sms, sent_at: 5.minutes.ago }
      let!(:old_sms) { create :campaign_sms, sent_at: 2.hours.ago }

      it "does nothing" do
        perform_job

        expect(CampaignSms).not_to have_received(:create_or_find_for)
      end
    end

    context "when flag disabled and not rate limited" do
      let(:scope) { :all_eligible }
      context "with an eligible campaign contact" do
        let!(:campaign_contact) { create(:campaign_contact, :sms_opted_in) }

        it "creates CampaignSms with sms-body, message name, phone number" do
          perform_job

          expect(CampaignSms).to have_received(:create_or_find_for).exactly(1).times
          sms = CampaignSms.last
          expect(sms.campaign_contact_id).to eq campaign_contact.id
          expect(sms.message_name).to eq message_name
          expect(sms.scheduled_send_at).to be_within(2.minutes).of(Time.current + 15.minutes)
          expect(sms.body).to eq CampaignMessage::StartOfSeasonOutreach.new.sms_body(contact: campaign_contact)
          expect(sms.to_phone_number).to eq campaign_contact.sms_phone_number
        end
      end

      context "with multiple eligible campaign contacts" do
        let!(:campaign_contacts) { create_list(:campaign_contact, 3, :sms_opted_in) }

        it "creates CampaignSms for all of them" do
          perform_job

          expect(CampaignSms).to have_received(:create_or_find_for).exactly(3).times
        end

        context "when queue_next_batch is true" do
          let(:queue_next_batch) { true }

          it "queues the next batch job" do
            expect { perform_job }.to have_enqueued_job(Campaign::SendSmsBatchJob)
          end
        end
      end

      context "when scope is recent_signups" do
        let(:scope) { :recent_signups }

        cutoff = Rails.configuration.tax_year_filing_seasons[MultiTenantService.new(:gyr).current_tax_year - 1].last
        let!(:contact_with_new_signup) { create(:campaign_contact, :sms_opted_in, latest_signup_at: cutoff + 1.day) }
        let!(:contact_with_old_signup) { create(:campaign_contact, :sms_opted_in, latest_signup_at: cutoff - 1.day) }

        it "only creates sms messages for campaign contacts with signups created after the cutoff" do
          perform_job

          expect(CampaignSms).to have_received(:create_or_find_for).exactly(1).time
        end
      end

      context "when scope is prior_fyst" do
        let(:scope) { :prior_fyst }
        let!(:contact_with_prior_fyst_record) do
          create :campaign_contact,
                 :sms_opted_in,
                 :with_state_file_ref
        end
        let!(:contact_without_prior_fyst_record) do
          create :campaign_contact,
                 :sms_opted_in,
                 state_file_intake_refs: []
        end

        it "only creates text messages for campaign contacts with records of prior-year FYST returns" do
          perform_job

          expect(CampaignSms).to have_received(:create_or_find_for).exactly(1).time
        end
      end

      context "when scope is prior_gyr" do
        let(:scope) { :prior_gyr }
        let!(:contact_with_prior_gyr_record) do
          create :campaign_contact,
                 :sms_opted_in,
                 :with_gyr_intake_ids
        end
        let!(:contact_without_prior_gyr_record) do
          create :campaign_contact,
                 :sms_opted_in,
                 gyr_intake_ids: []
        end

        it "only creates text messages for campaign contacts with records of prior-year GYR returns" do
          perform_job

          expect(CampaignSms).to have_received(:create_or_find_for).exactly(1).time
        end
      end
    end
  end
end
