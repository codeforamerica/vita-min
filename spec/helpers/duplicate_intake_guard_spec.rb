require "rails_helper"

RSpec.describe DuplicateIntakeGuard do
  let(:primary_consented_to_service) { "yes" }
  let(:primary_ssn) { "123456789" }
  let(:service_type) { "online_intake" }
  let!(:existing_intake) do
    create(
      :intake,
      email_address: "existing@client.com",
      phone_number: "+15005550006",
      primary_consented_to_service: primary_consented_to_service,
      primary_ssn: primary_ssn,
      client: build(:client, tax_returns: [build(:tax_return, service_type: service_type)])
    )
  end

  let(:subject) { DuplicateIntakeGuard.new(matching_intake) }

  describe "has_duplicate?" do
    context "intake with matching email address exists but different primary ssn" do
      let!(:matching_intake) { create(:intake, email_address: "existing@client.com", primary_ssn: "923456789") }

      it "returns false" do
        expect(subject).not_to have_duplicate
      end
    end

    context "intake with matching phone number exists but different primary ssn" do
      let!(:matching_intake) { create(:intake, phone_number: "+15005550006", primary_ssn: "923456789") }

      it "returns false if marching phone number but different intake" do
        expect(subject).not_to have_duplicate
      end
    end

    context "existing intake is missing primary ssn" do
      let(:primary_ssn) { nil }
      let(:matching_intake) { create(:intake, primary_ssn: nil) }

      it "there is no match without primary ssn" do
        expect(subject).not_to have_duplicate
      end

      it "there is no match with primary ssn" do
        matching_intake.update(primary_ssn: "123456789")
        expect(subject).not_to have_duplicate
      end
    end

    context "intake with matching primary ssn exists" do
      let(:primary_ssn) { "123456789" }
      let!(:matching_intake) { create(:intake, primary_ssn: "123456789") }

      context "service type is online_intake" do
        it "returns true if online intake and primary filer has consented" do
          existing_intake.update(primary_consented_to_service: "yes")
          expect(DuplicateIntakeGuard.new(matching_intake)).to have_duplicate
        end

        it "returns false if online intake and primary filer has not consented" do
          existing_intake.update(primary_consented_to_service: "no")
          expect(subject).not_to have_duplicate
        end
      end

      context "service type is drop_off" do
        let(:service_type) { "drop_off" }
        let(:primary_consented_to_service) { "unfilled" }

        it "returns true if service type is drop-off regardless of primary consented at value" do
          expect(subject).to have_duplicate

          existing_intake.update(primary_consented_to_service: "no")
          expect(subject).to have_duplicate
        end
      end
    end

    context "other intakes are duplicates with each other but not the current intake" do
      let!(:other_intake) { create(:intake, primary_ssn: "222456789", primary_consented_to_service: "yes", client: build(:client, tax_returns: [build(:tax_return, service_type: "online_intake")])) }
      let!(:other_matching_intake) { create(:intake, primary_ssn: "222456789", primary_consented_to_service: "yes", client: build(:client, tax_returns: [build(:tax_return, service_type: "online_intake")])) }

      it "returns false" do
        existing_intake.update(primary_consented_to_service: "yes")
        expect(DuplicateIntakeGuard.new(existing_intake)).not_to have_duplicate
      end
    end
  end
end
