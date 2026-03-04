require "rails_helper"

describe Campaign::SendEmailsBatchJob, type: :job do
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
    allow(Flipper).to receive(:enabled?).with(:cancel_campaign_emails).and_return(false)

    allow_any_instance_of(described_class).to receive(:rate_limited?).and_call_original

    allow(CampaignEmail).to receive(:create!).and_call_original
  end

  describe "#perform" do
    context "when :cancel_campaign_emails flag is enabled" do
      let!(:campaign_contact) { create(:campaign_contact, :email_opted_in) }

      it "does nothing" do
        allow(Flipper).to receive(:enabled?).with(:cancel_campaign_emails).and_return(true)

        perform_job

        expect(CampaignEmail).not_to have_received(:create!)
      end
    end

    context "when rate limiting is detected" do
      let!(:campaign_contact) { create(:campaign_contact, :email_opted_in) }

      let!(:rate_limited_1) do
        create(:campaign_email, mailgun_status: "failed", error_code: "421", sent_at: 5.minutes.ago)
      end
      let!(:rate_limited_2) do
        create(:campaign_email, mailgun_status: "failed", event_data: { reason: "rate limit exceeded" }, sent_at: 5.minutes.ago)
      end
      let!(:non_rate_limited) do
        create(:campaign_email, mailgun_status: "delivered", sent_at: 5.minutes.ago)
      end

      let!(:old_email) do
        create(:campaign_email, mailgun_status: "failed", error_code: "421", sent_at: 2.hours.ago)
      end

      it "does nothing (does not create new CampaignEmail records)" do
        perform_job

        expect(CampaignEmail).not_to have_received(:create!)
      end
    end

    context "when flag disabled and not rate limited" do
      before do
        allow_any_instance_of(described_class).to receive(:rate_limited?).and_return(false)
      end

      context "with an eligible campaign contact" do
        let!(:campaign_contact) { create(:campaign_contact, :email_opted_in, latest_gyr_intake_at: Rails.configuration.start_of_unique_links_only_intake - 1.day) }

        let!(:already_sent_campaign_contact) { create(:campaign_contact, :email_opted_in) }
        let!(:campaign_email) { create :campaign_email, message_name: message_name, campaign_contact: already_sent_campaign_contact }
        let!(:ineligible_campaign_contact) { create(:campaign_contact, :email_opted_in, latest_gyr_intake_at: Rails.configuration.start_of_unique_links_only_intake + 1.day) }

        it "creates a CampaignEmail with message name, to_email, scheduled_send_at" do
          perform_job

          expect(CampaignEmail).to have_received(:create!).exactly(1).times
          email = CampaignEmail.last
          expect(email.campaign_contact_id).to eq(campaign_contact.id)
          expect(email.message_name).to eq(message_name)
          expect(email.to_email).to eq(campaign_contact.email_address)
          expect(email.scheduled_send_at).to be_present
        end
      end

      context "with multiple eligible campaign contacts" do
        let!(:campaign_contacts) { create_list(:campaign_contact, 3, :email_opted_in) }

        it "creates CampaignEmail records for all of them" do
          perform_job

          expect(CampaignEmail).to have_received(:create!).exactly(3).times
        end

        context "when queue_next_batch is true" do
          let(:queue_next_batch) { true }

          it "queues the next batch job" do
            expect { perform_job }.to have_enqueued_job(Campaign::SendEmailsBatchJob)
          end
        end
      end

      context "when recent_signups_only is true" do
        let(:recent_signups_only) { true }
        cutoff = Rails.configuration.tax_year_filing_seasons[MultiTenantService.new(:gyr).current_tax_year - 1].last
        let!(:contact_with_new_signup) { create(:campaign_contact, :email_opted_in, latest_signup_at: cutoff + 1.day) }
        let!(:contact_with_old_signup) { create(:campaign_contact, :email_opted_in, latest_signup_at: cutoff - 1.day) }

        it "only creates emails for campaign contacts with signups created after the cutoff" do
          perform_job

          expect(CampaignEmail).to have_received(:create!).exactly(1).time
        end
      end
    end
  end
end
