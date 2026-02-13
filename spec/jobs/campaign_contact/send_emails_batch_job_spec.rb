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
      xit "does nothing" do
        allow(CampaignContact).to receive(:email_contacts_for).with(sent_at_column)
                                                              .and_return(CampaignContact.none)

        expect(CampaignMailer).not_to receive(:email_message)
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

      xit "claims the contacts by setting sent_at_column to now" do
        perform_job

        expect(contact_en.reload.public_send(sent_at_column)).to eq(Time.current)
        expect(contact_es.reload.public_send(sent_at_column)).to eq(Time.current)
        expect(contact_blank_locale.reload.public_send(sent_at_column)).to eq(Time.current)
      end

      xit "enqueues an email for each claimed contact with locale fallback to 'en'" do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        expect(CampaignMailer).to receive(:email_message).with(
          email_address: "a@example.com",
          message_name: message_name,
          locale: "en"
        ).and_return(mail)

        expect(CampaignMailer).to receive(:email_message).with(
          email_address: "b@example.com",
          message_name: message_name,
          locale: "es"
        ).and_return(mail)

        expect(CampaignMailer).to receive(:email_message).with(
          email_address: "c@example.com",
          message_name: message_name,
          locale: "en"
        ).and_return(mail)

        expect(mail).to receive(:deliver_later).exactly(3).times

        perform_job
      end

      xit "enqueues the next batch job" do
        allow(CampaignMailer).to receive_message_chain(:email_message, :deliver_later)

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

      xit "does not send emails and does not enqueue the next batch" do
        expect(CampaignMailer).not_to receive(:email_message)
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

        expect(CampaignMailer).not_to receive(:email_message)
        expect(described_class).not_to receive(:perform_later)

        perform_job
      end
    end
  end
end
