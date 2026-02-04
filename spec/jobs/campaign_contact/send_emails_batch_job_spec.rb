require "rails_helper"

RSpec.describe CampaignContacts::SendEmailsBatchJob, type: :job do
  include ActiveJob::TestHelper

  subject(:perform_job) { described_class.new.perform(message_name, sent_at_column) }

  let(:message_name) { "preseason_outreach" }
  let(:sent_at_column) { :gyr_2025_preseason_email }

  before do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe "#perform" do
    around do |example|
      freeze_time { example.run }
    end

    context "when there are no eligible contacts" do
      it "does nothing" do
        allow(CampaignContact).to receive(:email_contacts_for).with(sent_at_column)
                                                              .and_return(CampaignContact.none)

        expect(CampaignEmail).not_to receive(:create)
        expect(described_class).not_to receive(:perform_later)

        perform_job
      end
    end

    context "when there are eligible contacts" do
      let!(:contact_en) do
        create(:campaign_contact, email_address: "a@example.com", locale: "en", sent_at_column => nil)
      end

      let!(:contact_es) do
        create(:campaign_contact, email_address: "b@example.com", locale: "es", sent_at_column => nil)
      end

      let!(:contact_blank_locale) do
        create(:campaign_contact, email_address: "c@example.com", locale: nil, sent_at_column => nil)
      end

      before do
        allow(CampaignContact).to receive(:email_contacts_for).with(sent_at_column)
                                                              .and_return(CampaignContact.where(id: [contact_en.id, contact_es.id, contact_blank_locale.id]))
      end

      it "claims the contacts by setting sent_at_column to now" do
        perform_job

        expect(contact_en.reload.public_send(sent_at_column)).to eq(Time.current)
        expect(contact_es.reload.public_send(sent_at_column)).to eq(Time.current)
        expect(contact_blank_locale.reload.public_send(sent_at_column)).to eq(Time.current)
      end

      it "creates a CampaignEmail for each claimed contact" do
        expect(CampaignEmail).to receive(:create).with(
          campaign_contact_id: contact_en.id,
          message_name: message_name,
          to_email: "a@example.com",
          )

        expect(CampaignEmail).to receive(:create).with(
          campaign_contact_id: contact_es.id,
          message_name: message_name,
          to_email: "b@example.com",
          )

        expect(CampaignEmail).to receive(:create).with(
          campaign_contact_id: contact_blank_locale.id,
          message_name: message_name,
          to_email: "c@example.com",
          )

        perform_job
      end

      it "enqueues the next batch job" do
        expect(described_class).to receive(:perform_later).with(message_name, sent_at_column)
        perform_job
      end
    end

    context "when ids are returned but none can be claimed (concurrent runner already claimed them)" do
      let!(:contact) do
        create(:campaign_contact, email_address: "a@example.com", locale: "en", sent_at_column => nil)
      end

      before do
        allow(CampaignContact).to receive(:email_contacts_for).with(sent_at_column)
                                                              .and_return(CampaignContact.where(id: contact.id))

        allow(CampaignContact).to receive_message_chain(:where, :update_all).and_return(0)
      end

      it "does not create CampaignEmails and does not enqueue the next batch" do
        expect(CampaignEmail).not_to receive(:create)
        expect(described_class).not_to receive(:perform_later)

        perform_job
      end
    end

    context "batching" do
      it "only processes up to BATCH_SIZE contacts per run" do
        scope = instance_double(ActiveRecord::Relation)

        expect(CampaignContact).to receive(:email_contacts_for).with(sent_at_column).and_return(scope)
        expect(scope).to receive(:limit).with(described_class::BATCH_SIZE).and_return(scope)
        expect(scope).to receive(:pluck).with(:id).and_return([])

        expect(CampaignEmail).not_to receive(:create)
        expect(described_class).not_to receive(:perform_later)

        perform_job
      end
    end
  end
end
