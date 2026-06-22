require "rails_helper"

RSpec.describe NotificationsSettingsController do
  describe "#unsubscribe_from_emails" do
    render_views

    let!(:intake) { create :intake, email_address: "unsubscribe_me@example.com", email_notification_opt_in: "yes" }
    let(:verifier) { ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base) }
    let(:signed_email) { verifier.generate("unsubscribe_me@example.com") }
    let(:signed_email_without_intake) { verifier.generate("rando@example.com") }

    it "unsubscribes the intake from email" do
      get :unsubscribe_from_emails, params: { email_address: signed_email }

      expect(intake.reload.email_notification_opt_in).to eq "no"
      expect(intake.reload.email_unsubscribed_at).to be_within(30.seconds).of(DateTime.now)
      expect(response.body).to include subscribe_to_emails_path(email_address: signed_email)
    end

    it "stores email_unsubscribed_at when unsubscribing" do
      freeze_time do
        get :unsubscribe_from_emails, params: { email_address: signed_email }

        expect(intake.reload.email_unsubscribed_at).to eq Time.current
      end
    end

    context "no matching intakes" do
      it "shows a message" do
        get :unsubscribe_from_emails, params: { email_address: signed_email_without_intake }

        expect(flash[:alert]).to eq "No record found"
      end
    end

    context "unsigned email" do
      it "shows a message" do
        get :unsubscribe_from_emails, params: { email_address: "unsubscribe_me@example.com" }

        expect(flash[:alert]).to eq "Invalid subscription link"
      end
    end

    context "no email address" do
      let!(:intake) { create :intake, email_address: nil }

      it "does not match with intakes that have nil email address" do
        get :unsubscribe_from_emails

        expect(flash[:alert]).to eq "No record found"
      end
    end
  end

  describe "#subscribe_to_emails" do
    let!(:intake) { create :intake, email_address: "unsubscribe_me@example.com", email_notification_opt_in: "no" }
    let!(:matching_intake) { create :intake, email_address: "unsubscribe_me@example.com", email_notification_opt_in: "no" }
    let(:verifier) { ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base) }
    let(:signed_email) { verifier.generate("unsubscribe_me@example.com") }
    let(:signed_email_without_intake) { verifier.generate("rando@example.com") }

    it "resubscribes all intakes with matching email to email notifications" do
      post :subscribe_to_emails, params: { email_address: signed_email }

      expect(intake.reload.email_notification_opt_in).to eq "yes"
      expect(matching_intake.reload.email_notification_opt_in).to eq "yes"
      expect(flash[:notice]).to eq "You are successfully re-subscribed to email notifications."
    end

    it "clears email_unsubscribed_at when resubscribing" do
      intake.update!(email_unsubscribed_at: 1.day.ago)
      matching_intake.update!(email_unsubscribed_at: 1.day.ago)

      post :subscribe_to_emails, params: { email_address: signed_email }

      expect(intake.reload.email_unsubscribed_at).to be_nil
      expect(matching_intake.reload.email_unsubscribed_at).to be_nil
    end

    context "no matching intakes" do
      it "shows a message" do
        get :subscribe_to_emails, params: { email_address: signed_email_without_intake }

        expect(flash[:alert]).to eq "No record found"
      end
    end

    context "unsigned email" do
      it "shows a message" do
        get :subscribe_to_emails, params: { email_address: "unsubscribe_me@example.com" }

        expect(flash[:alert]).to eq "Invalid subscription link"
      end
    end

    context "no email address" do
      let!(:intake) { create :intake, email_address: nil }

      it "does not match with intakes that have nil email address" do
        get :subscribe_to_emails

        expect(flash[:alert]).to eq "No record found"
      end
    end
  end

  describe "#unsubscribe_from_campaign_emails" do
    let(:verifier) { ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base) }
    let(:email_address) { "campaign@example.com" }
    let(:signed_email) { verifier.generate(email_address) }

    let!(:contact) do
      create(
        :campaign_contact,
        email_address: email_address,
        email_notification_opt_in: true,
        email_unsubscribed_at: nil
      )
    end

    before do
      allow(DatadogApi).to receive(:increment)
    end

    it "unsubscribes the campaign contact from email" do
      freeze_time do
        get :unsubscribe_from_campaign_emails, params: { email_address: signed_email }

        contact.reload
        expect(contact.email_notification_opt_in).to eq false
        expect(contact.email_unsubscribed_at).to eq Time.current
      end
    end

    it "tracks the campaign unsubscribe metric" do
      get :unsubscribe_from_campaign_emails, params: { email_address: signed_email }

      expect(DatadogApi).to have_received(:increment).with(
        "email.unsubscribes.count", tags: ["last_email:unknown_email", "email_type:campaign"]
      )
    end
  end

  describe "#subscribe_to_campaign_emails" do
    let(:verifier) { ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base) }
    let(:email_address) { "campaign@example.com" }
    let(:signed_email) { verifier.generate(email_address) }

    let!(:contact) do
      create(
        :campaign_contact,
        email_address: email_address,
        email_notification_opt_in: false,
        email_unsubscribed_at: 1.day.ago
      )
    end

    before do
      allow(DatadogApi).to receive(:increment)
    end

    it "resubscribes the campaign contact to email" do
      get :subscribe_to_campaign_emails, params: { email_address: signed_email }

      contact.reload
      expect(contact.email_notification_opt_in).to eq true
      expect(contact.email_unsubscribed_at).to be_nil
    end

    it "does not track an unsubscribe metric" do
      get :subscribe_to_campaign_emails, params: { email_address: signed_email }

      expect(DatadogApi).not_to have_received(:increment)
    end
  end
end
