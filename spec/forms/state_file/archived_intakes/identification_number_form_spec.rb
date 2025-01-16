require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::IdentificationNumberForm do
  let(:intake_ssn) { "123456789" }
  let(:hashed_ssn) { SsnHashingService.hash(intake_ssn) }
  let(:input_ssn) { "1234" }
  let(:form) { described_class.new({ssn: input_ssn}, hashed_ssn) }


  describe "validations" do
    context "with an input that does not look like an ssn" do
      let(:input_ssn) { "1234" }

      it "is not valid and adds a validation error" do
        expect(form).not_to be_valid
        expect(form.errors).to include :ssn
      end
    end

    context "with an empty input" do
      let(:input_ssn) { "" }

      it "is not valid and adds a validation error" do
        expect(form).not_to be_valid
        expect(form.errors).to include :ssn
      end
    end

    context "with a valid matching ssn input" do
      let(:input_ssn) { "123-45-6789" }

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end
end
