require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::IdentificationNumberForm do
  let(:intake_ssn) { "123456789" }
  let(:hashed_ssn) { SsnHashingService.hash(intake_ssn) }
  let(:input_ssn) { "1234" }
  let(:archived_intake) {
    build(:state_file_archived_intake, hashed_ssn: hashed_ssn)
  }
  let(:state_file_archived_intake_request) { build(:state_file_archived_intake_request, state_file_archived_intake: archived_intake) }
  let(:form) { described_class.new(state_file_archived_intake_request, {ssn: input_ssn}) }
  
  # we always will have intake request for every test 
  # input & archive intake match 
  # input & archive intake don't match 
  # input & no archived intake

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
