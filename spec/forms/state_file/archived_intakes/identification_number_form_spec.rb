require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::IdentificationNumberForm do
  let(:intake_ssn) { "123456789" }
  let(:hashed_ssn) { SsnHashingService.hash(intake_ssn) }
  let(:input_ssn) { "1234" }
  let(:state_file_archived_intake) {
    build(:state_file_archived_intake, hashed_ssn: hashed_ssn)
  }

  let(:form) { described_class.new(state_file_archived_intake, {ssn: input_ssn}) }

  describe "validations" do
    context "with an input that does not look like an ssn" do
      let(:input_ssn) { "1234" }

      it "is not valid and adds a validation error" do
        expect(form).not_to be_valid
        expect(form.errors).to include :ssn
        expect(form.errors[:ssn]).to include I18n.t("state_file.archived_intakes.identification_number.edit.error_message")
      end
    end

    context "with an empty input" do
      let(:input_ssn) { "" }

      it "is not valid and adds a validation error" do
        expect(form).not_to be_valid
        expect(form.errors).to include :ssn
        expect(form.errors[:ssn]).to include "Can't be blank."
      end
    end

    context "with a valid matching ssn input and with a matching intake" do
      let(:input_ssn) { "123-45-6789" }

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end
end
