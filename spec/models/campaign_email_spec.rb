# == Schema Information
#
# Table name: campaign_emails
#
#  id                  :bigint           not null, primary key
#  error_code          :string
#  event_data          :jsonb
#  from_email          :string
#  mailgun_status      :string           default("created"), not null
#  message_name        :string
#  scheduled_send_at   :datetime
#  sent_at             :datetime
#  subject             :text
#  to_email            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  campaign_contact_id :bigint           not null
#  mailgun_message_id  :string
#
# Indexes
#
#  index_campaign_emails_on_campaign_contact_id          (campaign_contact_id)
#  index_campaign_emails_on_contact_id_and_message_name  (campaign_contact_id,message_name) UNIQUE
#  index_campaign_emails_on_mailgun_message_id           (mailgun_message_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (campaign_contact_id => campaign_contacts.id)
#
require "rails_helper"

RSpec.describe CampaignEmail, type: :model do
  include ActiveJob::TestHelper

  before do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe "associations" do
    it { is_expected.to belong_to(:campaign_contact) }
  end

  describe "validations" do
    it "validates inclusion of mailgun_status" do
      email = build(:campaign_email, mailgun_status: "not-a-real-status")
      expect(email).not_to be_valid
      expect(email.errors[:mailgun_status]).to be_present
    end
  end

  describe "scopes" do
    let!(:successful_email_1) { create(:campaign_email, mailgun_status: "delivered") }
    let!(:successful_email_2) { create(:campaign_email, mailgun_status: "opened") }
    let!(:failed_email_1) { create(:campaign_email, mailgun_status: "failed") }
    let!(:failed_email_2) { create(:campaign_email, mailgun_status: "permanent_fail") }
    let!(:in_progress_email_1) { create(:campaign_email, mailgun_status: "created") }
    let!(:in_progress_email_2) { create(:campaign_email, mailgun_status: "sending") }

    it ".succeeded returns only successful statuses" do
      expect(described_class.succeeded).to contain_exactly(successful_email_1, successful_email_2)
    end

    it ".failed returns only failed statuses" do
      expect(described_class.failed).to contain_exactly(failed_email_1, failed_email_2)
    end

    it ".in_progress returns only in-progress statuses" do
      expect(described_class.in_progress).to contain_exactly(in_progress_email_1, in_progress_email_2)
    end
  end

  describe "after_create :deliver" do
    around do |example|
      Timecop.freeze(Time.zone.parse("2026-02-06 10:00:00")) { example.run }
    ensure
      Timecop.return
    end

    let(:contact) { create(:campaign_contact) }

    context "when scheduled_send_at is blank" do
      it "enqueues SendCampaignEmailJob immediately" do
        expect do
          create(:campaign_email, :with_delivery, campaign_contact: contact, scheduled_send_at: nil)
        end.to have_enqueued_job(CampaignContacts::SendCampaignEmailJob).with(kind_of(Integer))
      end
    end

    context "when scheduled_send_at is in the past" do
      it "enqueues SendCampaignEmailJob immediately" do
        email = create(:campaign_email, campaign_contact: contact, scheduled_send_at: 5.minutes.ago)

        expect do
          email.send(:deliver)
        end.to have_enqueued_job(CampaignContacts::SendCampaignEmailJob).with(email.id)
      end
    end

    context "when scheduled_send_at is in the future" do
      it "enqueues SendCampaignEmailJob at scheduled_send_at" do
        scheduled_time = 30.minutes.from_now
        email = create(:campaign_email, campaign_contact: contact, scheduled_send_at: scheduled_time)

        expect do
          email.send(:deliver)
        end.to have_enqueued_job(CampaignContacts::SendCampaignEmailJob).with(email.id).at(scheduled_time)
      end
    end


    context "when validating mailgun_status inclusion" do
      it "allows all known statuses" do
        CampaignEmail::ALL_KNOWN_MAILGUN_STATUSES.each do |status|
          email = build(:campaign_email, campaign_contact: contact, mailgun_status: status)
          expect(email).to be_valid, "expected #{status.inspect} to be valid"
        end
      end
    end
  end
end
