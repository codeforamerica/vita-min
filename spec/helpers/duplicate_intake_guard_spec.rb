require "rails_helper"

RSpec.describe DuplicateIntakeGuard do
  let!(:existing_intake) do
    create(
      :intake,
      email_address: "existing@client.com",
      intake_pdf_sent_to_zendesk: "yes"
    )
  end

  let(:subject) { DuplicateIntakeGuard.new(matching_intake) }

  describe "has_duplicate?" do
    context "intake with matching email address exists" do
      let!(:existing_intake) { create(:intake, email_address: "existing@client.com") }
      let(:matching_intake) { create(:intake, email_address: "existing@client.com") }

      it "returns false if the intake pdf has not been sent to zendesk" do
        expect(subject).not_to have_duplicate
      end

      it "returns true if the intake pdf has been sent to zendesk" do
        existing_intake.update(intake_pdf_sent_to_zendesk: true)
        expect(subject).to have_duplicate
      end
    end

    context "intake with matching phone number exists" do
      let!(:existing_intake) { create(:intake, phone_number: "1234567890") }
      let(:matching_intake) { create(:intake, phone_number: "1234567890") }

      it "returns false if the intake pdf has not been sent to zendesk" do
        expect(subject).not_to have_duplicate
      end

      it "returns true if the intake pdf has been sent to zendesk" do
        existing_intake.update(intake_pdf_sent_to_zendesk: true)
        expect(subject).to have_duplicate
      end
    end

    context "existing intake is missing email address and phone number" do
      let!(:existing_intake) { create(:intake, intake_pdf_sent_to_zendesk: true) }
      let(:matching_intake) { create(:intake) }

      it "there is no match without phone and email" do
        expect(subject).not_to have_duplicate
      end

      it "there is no match with email address" do
        matching_intake.update(email_address: "new@email.com")
        expect(subject).not_to have_duplicate
      end

      it "there is no match with phone number" do
        matching_intake.update(phone_number: "1234567890")
        expect(subject).not_to have_duplicate
      end
    end
  end
end
