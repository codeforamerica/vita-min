require "rails_helper"

RSpec.describe StateFile::IntakeLoginForm do
  let(:matching_ssn) { "123456789" }
  let(:hashed_ssn) { SsnHashingService.hash(matching_ssn) }
  let(:intake) { create :state_file_az_intake_after_transfer, hashed_ssn: hashed_ssn }
  let(:other_intake) { create :state_file_az_intake_after_transfer }
  let(:possible_intakes) { StateFileAzIntake.where(id: [intake, other_intake]) }
  let(:raw_ssn) { nil }
  let(:params) { { possible_intakes: possible_intakes, ssn: raw_ssn } }
  let(:form) { described_class.new(params) }

  describe "validations" do
    context "with an input that does not look like an ssn" do
      let(:raw_ssn) { "1234" }

      it "is not valid and adds a validation error" do
        expect(form).not_to be_valid
        expect(form.errors).to include :ssn
      end
    end

    context "with an empty input" do
      let(:raw_ssn) { "" }

      it "is not valid and adds a validation error" do
        expect(form).not_to be_valid
        expect(form.errors).to include :ssn
      end
    end

    context "with a valid matching ssn input" do
      let(:raw_ssn) { "123-45-6789" }

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end

  describe "#intake" do
    context "when there are no given possible intakes" do
      let(:possible_intakes) { nil }

      it "raises an argument error" do
        expect { form.intake }.to raise_error ArgumentError
      end
    end

    context "when the hashed SSN matches an existing intake" do
      let(:raw_ssn) { "123-45-6789" }

      it "returns the matching intake" do
        expect(form.intake).to eq intake
      end
    end

    context "with a valid-looking SSN that doesn't match an intake" do
      let(:raw_ssn) { "187-65-4321" }

      it "adds an extra special validation error and returns nil" do
        expect(form.intake).to be_nil
        expect(form).not_to be_valid
        expect(form.errors[:ssn]).to include I18n.t("state_file.intake_logins.form.errors.bad_input")
        expect(form.errors).to include :failed_ssn_match
      end
    end
  end
end