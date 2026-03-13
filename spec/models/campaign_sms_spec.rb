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
    let(:campaign_contact) { create(:campaign_contact, sms_notification_opt_in: true) }

    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it "enqueues SendCampaignSmsJob immediately" do
      expect {
        create(:campaign_sms, campaign_contact: campaign_contact)
      }.to have_enqueued_job(Campaign::SendCampaignSmsJob)
             .with(kind_of(Integer))
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

  describe ".create_or_find_for" do
    subject(:create_or_find) do
      described_class.create_or_find_for(contact: contact, message_name: message_name, scheduled_send_at: scheduled_send_at)
    end

    let(:contact) { create(:campaign_contact, sms_phone_number: "+15551234567") }
    let(:message_name) { "start_of_season_outreach" }
    let(:scheduled_send_at) { 1.hour.from_now }

    context "when the message class does not exist" do
      let(:message_name) { "fdskfjdk" }

      it "returns nil" do
        expect(create_or_find).to be_nil
      end

      it "does not create a CampaignSms record" do
        expect { create_or_find }.not_to change(CampaignSms, :count)
      end
    end

    context "when the message class exists but sms_body returns nil" do
      before do
        allow_any_instance_of(CampaignMessage::StartOfSeasonOutreach).to receive(:sms_body).and_return(nil)
      end

      it "returns nil" do
        expect(create_or_find).to be_nil
      end

      it "does not create a CampaignSms record" do
        expect { create_or_find }.not_to change(CampaignSms, :count)
      end
    end

    context "when the message class and body are present" do
      context "and no existing record exists" do
        it "creates and returns a new CampaignSms" do
          expect { create_or_find }.to change(CampaignSms, :count).by(1)
        end

        it "sets the correct attributes" do
          sms = create_or_find

          expect(sms).to have_attributes(
                           campaign_contact_id: contact.id,
                           message_name: message_name,
                           to_phone_number: contact.sms_phone_number,
                           body: "Hi Test! GetYourRefund is back for the new tax season. We'd love to help you file for free again this year. Our IRS-certified team is ready when you are: https://www.getyourrefund.org/outreach",
                           scheduled_send_at: scheduled_send_at
                         )
        end
      end

      context "and a record already exists for the same phone number and message_name" do
        let!(:existing_sms) do
          create(:campaign_sms,
                 campaign_contact: contact,
                 message_name: message_name,
                 to_phone_number: contact.sms_phone_number
          )
        end

        it "does not create a new record" do
          expect { create_or_find }.not_to change(CampaignSms, :count)
        end

        it "returns the existing record" do
          expect(create_or_find).to eq(existing_sms)
        end
      end
    end
  end
end
