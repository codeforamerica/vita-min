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
      expect(response.body).to include subscribe_to_emails_path(email_address: signed_email)
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

        expect(flash[:alert]).to eq "Invalid unsubscribe link"
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

    context "no matching intakes" do
      it "shows a message" do
        get :subscribe_to_emails, params: { email_address: signed_email_without_intake }

        expect(flash[:alert]).to eq "No record found"
      end
    end

    context "unsigned email" do
      it "shows a message" do
        get :subscribe_to_emails, params: { email_address: "unsubscribe_me@example.com" }

        expect(flash[:alert]).to eq "Invalid subscribe link"
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
end
