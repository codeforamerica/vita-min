require "rails_helper"

describe Campaign::SendEmailsBatchJob, type: :job do
  include ActiveJob::TestHelper

  subject(:perform_job) do
    described_class.new.perform(
      message_name,
      batch_size: batch_size,
      batch_delay: batch_delay,
      queue_next_batch: queue_next_batch
    )
  end

  let(:message_name) { "start_of_season_outreach" }
  let(:batch_size) { 100 }
  let(:batch_delay) { 1.minute }
  let(:queue_next_batch) { false }

  before do
    clear_enqueued_jobs
    clear_performed_jobs

    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:cancel_campaign_emails).and_return(false)

    allow_any_instance_of(described_class).to receive(:rate_limited?).and_return(false)
  end

  describe "#perform" do
    around do |example|
      est_time = Time.find_zone!("America/New_York")
      fake_time = est_time.parse("2026-02-06 10:00:00")

      Timecop.freeze(fake_time) { example.run }
    ensure
      Timecop.return
    end

    context "when cancel flag is enabled" do
      it "does nothing" do
        allow(Flipper).to receive(:enabled?).with(:cancel_campaign_emails).and_return(true)

        expect(CampaignContact).not_to receive(:eligible_for_email)
        expect(CampaignEmail).not_to receive(:create!)

        perform_job
      end
    end

    context "when rate limited" do
      it "does nothing" do
        allow_any_instance_of(described_class).to receive(:rate_limited?).and_return(true)

        expect(CampaignContact).not_to receive(:eligible_for_email)
        expect(CampaignEmail).not_to receive(:create!)

        perform_job
      end
    end

    context "when there are no eligible contacts" do
      it "does nothing" do
        scope = double("CampaignContact scope")

        expect(CampaignContact).to receive(:eligible_for_email).and_return(scope)
        expect(scope).to receive(:limit).with(batch_size).and_return(scope)
        expect(scope).to receive(:pluck).with(:id).and_return([])

        expect(CampaignEmail).not_to receive(:create!)
        expect { perform_job }.not_to have_enqueued_job(described_class)
      end
    end


    context "when there are eligible contacts" do
      let!(:contact_en) { create(:campaign_contact, email_address: "a@example.com", locale: "en") }
      let!(:contact_es) { create(:campaign_contact, email_address: "b@example.com", locale: "es") }
      let!(:contact_blank_locale) { create(:campaign_contact, email_address: "c@example.com", locale: nil) }

      let(:ids) { [contact_en.id, contact_es.id, contact_blank_locale.id] }

      before do
        scope = double("CampaignContact scope")

        allow(CampaignContact).to receive(:eligible_for_email).and_return(scope)
        allow(scope).to receive(:not_emailed).with(message_name).and_return(scope)
        allow(scope).to receive(:limit).with(batch_size).and_return(scope)
        allow(scope).to receive(:pluck).with(:id).and_return(ids)

        allow(CampaignContact).to receive(:where).with(id: ids)
                                                 .and_return(CampaignContact.where(id: ids))
      end

      it "creates a CampaignEmail for each contact, with staggered scheduled_send_at" do
        start_time = Time.current

        expect(CampaignEmail).to receive(:create!).with(
          campaign_contact_id: contact_en.id,
          message_name: message_name,
          to_email: "a@example.com",
          scheduled_send_at: start_time + 0.seconds
        )

        expect(CampaignEmail).to receive(:create!).with(
          campaign_contact_id: contact_es.id,
          message_name: message_name,
          to_email: "b@example.com",
          scheduled_send_at: start_time + 0.2.seconds
        )

        expect(CampaignEmail).to receive(:create!).with(
          campaign_contact_id: contact_blank_locale.id,
          message_name: message_name,
          to_email: "c@example.com",
          scheduled_send_at: start_time + 0.4.seconds
        )

        perform_job
      end

      context "when CampaignEmail is not unique for contact" do
        it "skips that contact and continues" do
          allow(CampaignEmail).to receive(:create!).and_wrap_original do |m, *args|
            attrs = args.first
            raise ActiveRecord::RecordNotUnique if attrs[:campaign_contact_id] == contact_en.id
            m.call(*args)
          end

          perform_job

          expect(CampaignEmail).to have_received(:create!).with(hash_including(campaign_contact_id: contact_es.id))
          expect(CampaignEmail).to have_received(:create!).with(hash_including(campaign_contact_id: contact_blank_locale.id))
        end
      end

      context "when queue_next_batch is true" do
        let(:queue_next_batch) { true }

        it "enqueues the next batch job with a delay" do
          expect { perform_job }.to have_enqueued_job(described_class)
                                      .with(message_name, batch_size: batch_size, batch_delay: batch_delay)
                                      .at(Time.current + batch_delay)
        end
      end

      context "when queue_next_batch is false" do
        let(:queue_next_batch) { false }

        it "does not enqueue the next batch job" do
          expect { perform_job }.not_to have_enqueued_job(described_class)
        end
      end
    end

    context "batching" do
      let(:batch_size) { 123 }

      it "only processes up to batch_size contacts per run" do
        scope = double("CampaignContact scope")

        expect(CampaignContact).to receive(:eligible_for_email).and_return(scope)
        expect(scope).to receive(:limit).with(batch_size).and_return(scope)
        expect(scope).to receive(:pluck).with(:id).and_return([])

        expect(CampaignEmail).not_to receive(:create!)
        perform_job
      end
    end
  end
end
