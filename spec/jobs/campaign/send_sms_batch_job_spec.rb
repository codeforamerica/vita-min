require "rails_helper"

describe Campaign::SendSmsBatchJob, type: :job do
  include ActiveJob::TestHelper

  subject(:perform_job) do
    described_class.new.perform(
      message_name,
      batch_size: batch_size,
      batch_delay: batch_delay,
      queue_next_batch: queue_next_batch,
      recent_signups_only: recent_signups_only
    )
  end

  let(:message_name) { "start_of_season_outreach" }
  let(:batch_size) { 10 }
  let(:batch_delay) { 10.seconds }
  let(:queue_next_batch) { false }
  let(:recent_signups_only) { false }

  before do
    clear_enqueued_jobs
    clear_performed_jobs

    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:cancel_campaign_sms).and_return(false)

    allow_any_instance_of(described_class).to receive(:rate_limited?).and_call_original

    allow(CampaignSms).to receive(:create!).and_call_original
  end

  describe "#perform" do
    context "when :cancel_campaign_sms flag is enabled" do
      let!(:campaign_contact) { create(:campaign_contact, :sms_opted_in) }

      it "does nothing" do
        allow(Flipper).to receive(:enabled?).with(:cancel_campaign_sms).and_return(true)

        perform_job

        expect(CampaignSms).to_not have_received(:create!)
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

        expect(CampaignSms).not_to have_received(:create!)
      end
    end

    context "when flag disabled and not rate limited" do
      context "with an eligible campaign contact" do
        let!(:campaign_contact) { create(:campaign_contact, :sms_opted_in) }

        it "creates CampaignSms with sms-body, message name, phone number" do
          perform_job

          expect(CampaignSms).to have_received(:create!).exactly(1).times
          sms = CampaignSms.last
          expect(sms.campaign_contact_id).to eq campaign_contact.id
          expect(sms.message_name).to eq message_name
          expect(sms.body).to eq CampaignMessage::StartOfSeasonOutreach.new.sms_body(contact: campaign_contact)
          expect(sms.to_phone_number).to eq campaign_contact.sms_phone_number
        end
      end

      context "with multiple eligible campaign contacts" do
        let!(:campaign_contacts) { create_list(:campaign_contact, 3, :sms_opted_in) }

        it "creates CampaignSms for all of them" do
          perform_job

          expect(CampaignSms).to have_received(:create!).exactly(3).times
        end

        context "when queue_next_batch is true" do
          let(:queue_next_batch) { true }

          it "queues the next batch job" do
            expect { perform_job }.to have_enqueued_job(Campaign::SendSmsBatchJob)
          end
        end
      end

      context "when recent_signups_only is true" do
        let(:recent_signups_only) { true }

        let!(:old_signup) { create(:signup, email_address: nil, phone_number: "+15557775555", name: "old") }
        let!(:recent_signup) { create(:signup, email_address: nil, phone_number: "+15552345555", name: "new") }

        before do
          old_signup.update!(created_at: 2.years.ago)
        end

        it "only creates sms messages for campaign contacts with signups created after the cutoff" do
          perform_job

          expect(CampaignSms).to have_received(:create!).exactly(1).time
          expect(CampaignSms.last.campaign_contact.sign_up_ids.first).to eq recent_signup.id
        end
      end
    end
  end
end
