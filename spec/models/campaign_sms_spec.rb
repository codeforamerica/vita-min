# == Schema Information
#
# Table name: campaign_sms
#
#  id                  :bigint           not null, primary key
#  body                :text             not null
#  error_code          :string
#  event_data          :jsonb
#  message_name        :string           not null
#  scheduled_send_at   :datetime
#  sent_at             :datetime
#  to_phone_number     :string           not null
#  twilio_sid          :string
#  twilio_status       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  campaign_contact_id :bigint           not null
#
# Indexes
#
#  index_campaign_sms_on_campaign_contact_id               (campaign_contact_id)
#  index_campaign_sms_on_message_name_and_to_phone_number  (message_name,to_phone_number) UNIQUE
#  index_campaign_sms_on_twilio_sid                        (twilio_sid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (campaign_contact_id => campaign_contacts.id)
#
require "rails_helper"

RSpec.describe CampaignSms, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:campaign_contact) }
  end

  describe "validations" do
    it do
      is_expected.to validate_inclusion_of(:twilio_status).in_array(TwilioService::ALL_KNOWN_STATUSES)
    end
  end

  describe "scopes" do
    describe ".succeeded" do
      it "filters to successful statuses" do
        sms = described_class.where(twilio_status: TwilioService::SUCCESSFUL_STATUSES).pluck(:id)
        expect(described_class.succeeded.pluck(:id)).to match_array(sms)
      end
    end

    describe ".failed" do
      it "filters to failed statuses" do
        sms = described_class.where(twilio_status: TwilioService::FAILED_STATUSES).pluck(:id)
        expect(described_class.failed.pluck(:id)).to match_array(sms)
      end
    end

    describe ".in_progress" do
      it "filters to in-progress statuses" do
        sms = described_class.where(twilio_status: TwilioService::IN_PROGRESS_STATUSES).pluck(:id)
        expect(described_class.in_progress.pluck(:id)).to match_array(sms)
      end
    end
  end

  describe ".status_column" do
    it "returns :twilio_status" do
      expect(described_class.status_column).to eq(:twilio_status)
    end
  end

  describe "after_create" do
    let(:campaign_contact) { create(:campaign_contact) }

    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it "enqueues SendCampaignSmsJob immediately when scheduled_send_at is blank" do
      expect {
        create(:campaign_sms, campaign_contact: campaign_contact, scheduled_send_at: nil)
      }.to have_enqueued_job(Campaign::SendCampaignSmsJob)
             .with(kind_of(Integer))
    end

    it "enqueues SendCampaignSmsJob immediately when scheduled_send_at is in the past" do
      travel_to Time.zone.parse("2026-02-11 10:00:00") do
        expect {
          create(:campaign_sms, campaign_contact: campaign_contact, scheduled_send_at: 1.minute.ago)
        }.to have_enqueued_job(Campaign::SendCampaignSmsJob)
               .with(kind_of(Integer))
      end
    end

    it "schedules SendCampaignSmsJob when scheduled_send_at is in the future" do
      travel_to Time.zone.parse("2026-02-11 10:00:00") do
        sms = nil

        expect(Campaign::SendCampaignSmsJob).to receive(:set)
                                                  .with(wait_until: Time.zone.parse("2026-02-11 10:30:00"))
                                                  .and_call_original

        expect {
          sms = create(:campaign_sms, campaign_contact: campaign_contact, scheduled_send_at: Time.zone.parse("2026-02-11 10:30:00"))
        }.to have_enqueued_job(Campaign::SendCampaignSmsJob).with(kind_of(Integer))

        expect(sms.scheduled_send_at).to eq(Time.zone.parse("2026-02-11 10:30:00"))
      end
    end
  end

  describe "RecordsTwilioStatus integration" do
    let(:campaign_contact) { create(:campaign_contact) }

    it "updates status only if the new status is further in ORDERED_STATUSES" do
      sms = create(:campaign_sms, campaign_contact: campaign_contact, twilio_status: TwilioService::ORDERED_STATUSES.first)

      higher = TwilioService::ORDERED_STATUSES.last
      lower  = TwilioService::ORDERED_STATUSES.first

      sms.update_status_if_further(higher, error_code: "123")
      expect(sms.reload.twilio_status).to eq(higher)
      expect(sms.error_code).to eq("123")

      sms.update_status_if_further(lower, error_code: "999")
      expect(sms.reload.twilio_status).to eq(higher)
      expect(sms.error_code).to eq("123")
    end
  end
end
