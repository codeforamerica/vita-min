require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::IdentificationNumberForm do
  describe "#valid?" do
    context "when the ssn is present and valid" do
      it "returns true" do
        allow(SsnHashingService).to receive(:ssn).and_return("hashed_ssn")

        form = StateFile::ArchivedIntakes::IdentificationNumberForm.new(
          email_address: "test@example.com"
        )

        expect(form.valid?).to be true
      end
    end
  end
end
