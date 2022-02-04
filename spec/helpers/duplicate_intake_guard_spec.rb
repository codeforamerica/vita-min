require "rails_helper"

RSpec.describe DuplicateIntakeGuard do
  let!(:existing_intake) do
    create(
      :intake,
      email_address: "existing@client.com",
      primary_consented_to_service: "yes"
    )
  end

  let(:subject) { DuplicateIntakeGuard.new(matching_intake) }

  describe "has_duplicate?" do
    context "intake with matching email address exists" do
      let!(:existing_intake) { create(:intake, email_address: "existing@client.com", client: build(:client, tax_returns: [build(:tax_return, service_type: "online_intake")])) }
      let(:matching_intake) { create(:intake, email_address: "existing@client.com") }

      it "returns false if the intake is not completed" do
        expect(subject).not_to have_duplicate
      end

      it "returns true if the primary filer has consented" do
        existing_intake.update(primary_consented_to_service: "yes")
        expect(subject).to have_duplicate
      end
    end

    context "intake with matching phone number exists" do
      let!(:existing_intake) { create(:intake, phone_number: "+15005550006", client: build(:client, tax_returns: [build(:tax_return, service_type: "online_intake")])) }
      let(:matching_intake) { create(:intake, phone_number: "+15005550006") }

      it "returns false if the intake is not completed" do
        expect(subject).not_to have_duplicate
      end

      it "returns true if the primary filer has consented" do
        existing_intake.update(primary_consented_to_service: "yes")
        expect(subject).to have_duplicate
      end
    end

    context "existing intake is missing email address and phone number" do
      let!(:existing_intake) { create(:intake, primary_consented_to_service: "yes") }
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
  end
end
