require "rails_helper"

RSpec.describe StateFile::SmsTermsForm do
  let!(:intake) { create :state_file_az_intake }

  describe "#save" do
    context "consented_to_sms_terms is invalid" do
      let(:invalid_params) { {} }

      subject(:form) { described_class.new(intake, invalid_params) }

      it "is not valid" do
        form.valid?
        expect(form).to_not be_valid
      end
    end

    context "consented_to_sms_terms is valid" do
      let(:invalid_params) do
        {
          consented_to_sms_terms: "yes"
        }
      end
      subject(:form) { described_class.new(intake, invalid_params) }

      it "validates the form" do
        form.valid?
        expect(form).to be_valid
      end

      it "updates the intake with the provided attributes" do
        expect { form.save }.to change(intake, :consented_to_sms_terms).from("unfilled").to("yes")
      end
    end
  end
end
