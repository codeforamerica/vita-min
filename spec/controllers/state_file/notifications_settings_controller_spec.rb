require "rails_helper"

RSpec.describe StateFile::NotificationsSettingsController do
  describe "#unsubscribe_from_emails" do
    render_views

    let!(:intake) { create :state_file_ny_intake, email_address: "unsubscribe_me@example.com", unsubscribed_from_email: false }
    let(:verifier) { ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base) }
    let(:signed_email) { verifier.generate("unsubscribe_me@example.com") }
    let(:signed_email_without_intake) { verifier.generate("rando@example.com") }

    it "unsubscribes the intake from email" do
      get :unsubscribe_from_emails, params: { email_address: signed_email }

      expect(intake.reload.unsubscribed_from_email).to eq true
      expect(response.body).to include state_file_subscribe_to_emails_path(email_address: signed_email)
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
      let!(:intake) { create :state_file_ny_intake, email_address: nil }

      it "does not match with intakes that have nil email address" do
        get :unsubscribe_from_emails

        expect(flash[:alert]).to eq "No record found"
      end
    end
  end

  describe "#subscribe_email" do
    let!(:intake) { create :state_file_ny_intake, email_address: "unsubscribe_me@example.com", unsubscribed_from_email: true }
    let!(:matching_intake) { create :state_file_az_intake, email_address: "unsubscribe_me@example.com", unsubscribed_from_email: true }
    let(:verifier) { ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base) }
    let(:signed_email) { verifier.generate("unsubscribe_me@example.com") }
    let(:signed_email_without_intake) { verifier.generate("rando@example.com") }

    it "resubscribes all intakes with matching email to email notifications" do
      post :subscribe_to_emails, params: { email_address: signed_email }

      expect(intake.reload.unsubscribed_from_email).to eq false
      expect(matching_intake.reload.unsubscribed_from_email).to eq false
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

        expect(flash[:alert]).to eq "Invalid subscription link"
      end
    end

    context "no email address" do
      let!(:intake) { create :state_file_ny_intake, email_address: nil }

      it "does not match with intakes that have nil email address" do
        get :subscribe_to_emails

        expect(flash[:alert]).to eq "No record found"
      end
    end
  end
end