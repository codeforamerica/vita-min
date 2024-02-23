require "rails_helper"

RSpec.describe StateFile::NotificationsSettingsController do
  describe "#unsubscribe_email" do
    render_views

    let!(:intake) { create :state_file_ny_intake, email_address: "unsubscribe_me@example.com", unsubscribed_from_email: false }

    it "unsubscribes the intake from email" do
      get :unsubscribe_email, params: { email_address: "unsubscribe_me@example.com" }

      expect(intake.reload.unsubscribed_from_email).to eq true
      expect(response.body).to include state_file_subscribe_email_path(email_address: "unsubscribe_me@example.com")
    end

    context "no matching intakes" do
      it "shows a message" do
        get :unsubscribe_email, params: { email_address: "rando@example.com" }

        expect(flash[:alert]).to eq "No record found"
      end
    end

    context "no email address" do
      let!(:intake) { create :state_file_ny_intake, email_address: nil }

      it "does not match with intakes that have nil email address" do
        get :unsubscribe_email

        expect(flash[:alert]).to eq "No record found"
      end
    end
  end

  describe "#subscribe_email" do
    let!(:intake) { create :state_file_ny_intake, email_address: "unsubscribe_me@example.com", unsubscribed_from_email: true }
    let!(:matching_intake) { create :state_file_az_intake, email_address: "unsubscribe_me@example.com", unsubscribed_from_email: true }

    it "resubscribes all intakes with matching email to email notifications" do
      post :subscribe_email, params: { email_address: "unsubscribe_me@example.com" }

      expect(intake.reload.unsubscribed_from_email).to eq false
      expect(matching_intake.reload.unsubscribed_from_email).to eq false
      expect(flash[:notice]).to eq "You are successfully re-subscribed to email notifications."
    end

    context "no matching intakes" do
      it "shows a message" do
        get :subscribe_email, params: { email_address: "rando@example.com" }

        expect(flash[:alert]).to eq "No record found"
      end
    end

    context "no email address" do
      let!(:intake) { create :state_file_ny_intake, email_address: nil }

      it "does not match with intakes that have nil email address" do
        get :subscribe_email

        expect(flash[:alert]).to eq "No record found"
      end
    end
  end
end