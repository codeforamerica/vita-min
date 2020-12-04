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
      let!(:existing_intake) { create(:intake, phone_number: "+15005550006") }
      let(:matching_intake) { create(:intake, phone_number: "+15005550006") }

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
        matching_intake.update(phone_number: "+15005550006")
        expect(subject).not_to have_duplicate
      end
    end

    context "existing intake has same eip flag as current intake" do
      let(:existing_eip_intake) { create(:intake, :eip_only, email_address: "eip@client.com", intake_pdf_sent_to_zendesk: "yes") }
      let(:current_eip_intake) { create(:intake, :eip_only, email_address: existing_eip_intake.email_address) }
      let(:current_full_intake) { create(:intake, email_address: existing_intake.email_address) }

      it "returns true" do
        expect(DuplicateIntakeGuard.new(current_eip_intake)).to have_duplicate
        expect(DuplicateIntakeGuard.new(current_full_intake)).to have_duplicate
      end
    end

    context "existing intake has different eip flag from current intake" do
      let(:existing_eip_intake) { create(:intake, :eip_only, email_address: "was_eip@client.com", intake_pdf_sent_to_zendesk: "yes") }
      let(:current_full_intake) { create(:intake, email_address: existing_eip_intake.email_address) }
      let(:current_eip_intake) { create(:intake, :eip_only, email_address: existing_intake.email_address) }

      it "returns false" do
        expect(DuplicateIntakeGuard.new(current_full_intake)).not_to have_duplicate
        expect(DuplicateIntakeGuard.new(current_eip_intake)).not_to have_duplicate
      end
    end
  end
end
