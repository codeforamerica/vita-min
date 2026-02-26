require "rails_helper"

describe Campaign::SendEmailsBatchJob, type: :job do
  include ActiveJob::TestHelper

  subject(:perform_job) do
    described_class.new.perform(
      message_name: message_name,
      batch_size: batch_size,
      email_delay: email_delay,
      queue_next_batch: queue_next_batch,
      recent_signups_only: recent_signups_only
    )
  end

  let(:message_name) { "start_of_season_outreach" }
  let(:batch_size) { 10 }
  let(:email_delay) { 10.seconds }
  let(:queue_next_batch) { false }
  let(:recent_signups_only) { false }

  before do
    clear_enqueued_jobs
    clear_performed_jobs

    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:cancel_campaign_emails).and_return(false)
    allow(CampaignEmail).to receive(:create_or_find_for).and_call_original
  end

  describe "#perform" do
    context "when :cancel_campaign_emails flag is enabled" do
      let!(:campaign_contact) { create(:campaign_contact, :email_opted_in) }

      it "does nothing" do
        allow(Flipper).to receive(:enabled?).with(:cancel_campaign_emails).and_return(true)

        perform_job

        expect(CampaignEmail).not_to have_received(:create_or_find_for)
      end
    end

    context "when not paused and flag disabled" do
      context "with an eligible campaign contact" do
        let!(:campaign_contact) do
          create(:campaign_contact, :email_opted_in,
                 latest_gyr_intake_at: Rails.configuration.start_of_unique_links_only_intake - 1.day)
        end

        let!(:already_sent_campaign_contact) { create(:campaign_contact, :email_opted_in) }
        let!(:campaign_email) do
          create :campaign_email, message_name: message_name, campaign_contact: already_sent_campaign_contact
        end

        let!(:ineligible_campaign_contact) do
          create(:campaign_contact, :email_opted_in,
                 latest_gyr_intake_at: Rails.configuration.start_of_unique_links_only_intake + 1.day)
        end

        it "creates a CampaignEmail with correct attributes" do
          perform_job

          expect(CampaignEmail).to have_received(:create_or_find_for).exactly(1).times # ✅ updated

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

          expect(CampaignEmail).to have_received(:create_or_find_for).exactly(3).times # ✅ updated
        end

        context "when queue_next_batch is true" do
          let(:queue_next_batch) { true }

          it "queues the next batch job" do
            expect { perform_job }.to have_enqueued_job(Campaign::SendEmailsBatchJob)
          end
        end
      end

      context "when recent_signups_only is true" do
        cutoff = Rails.configuration.tax_year_filing_seasons[
          MultiTenantService.new(:gyr).current_tax_year - 1
        ].last

        let(:recent_signups_only) { true }

        let!(:contact_with_new_signup) do
          create(:campaign_contact, :email_opted_in, latest_signup_at: cutoff + 1.day)
        end

        let!(:contact_with_old_signup) do
          create(:campaign_contact, :email_opted_in, latest_signup_at: cutoff - 1.day)
        end

        it "only creates emails for recent signups" do
          perform_job

          expect(CampaignEmail).to have_received(:create_or_find_for).exactly(1).time
        end
      end
    end

    context "when a domain is paused" do
      let!(:contact) { create(:campaign_contact, :email_opted_in, email_address: "test@yahoo.com") }

      before do
        PausedEmailDomain.pause!("yahoo.com", minutes: 60)
      end

      it "skips creating emails for that domain" do
        perform_job

        expect(CampaignEmail).not_to have_received(:create_or_find_for)
      end
    end
  end
end