require "rails_helper"

RSpec.describe FileYourselfForm do
  let(:diy_intake) { DiyIntake.new }
  let(:valid_params) do
    {
      email_address: "example@example.com",
      preferred_first_name: "Robot",
      filing_frequency: "some_years",
    }
  end
  let(:additional_params) do
    {
      visitor_id: "visitor_1",
      source: "source",
      referrer: "referrer",
      locale: "es"
    }
  end

  describe "validations" do
    context "when all params are valid" do
      it "is valid" do
        form = described_class.new(diy_intake, valid_params.merge(additional_params))

        expect(form).to be_valid
      end
    end

    context "invalid params" do
      context "with invalid email" do
        let(:invalid_params) do
          {
            diy_intake: {
              email_address: "not an email address",
              preferred_first_name: "Robot",
              filing_frequency: "some_years",
            }
          }
        end

        it "adds an error" do
          form = described_class.new(diy_intake, invalid_params.merge(additional_params))

          expect(form).not_to be_valid
          expect(form.errors[:email_address]).to be_present
        end
      end

      context "missing params" do
        let(:invalid_params) do
          {
            diy_intake: {
              email_address: nil,
              preferred_first_name: nil,
              filing_frequency: nil,
            }
          }
        end

        it "adds an error for each" do
          form = described_class.new(diy_intake, invalid_params.merge(additional_params))

          expect(form).not_to be_valid
          expect(form.errors[:email_address]).to be_present
          expect(form.errors[:preferred_first_name]).to be_present
          expect(form.errors[:filing_frequency]).to be_present
        end
      end
    end
  end

  describe "#save" do
    it "saves the right attributes to the record" do
      form = described_class.new(diy_intake, valid_params.merge(additional_params))
      form.save

      diy_intake.reload
      expect(diy_intake.email_address).to eq "example@example.com"
      expect(diy_intake.preferred_first_name).to eq "Robot"
      expect(diy_intake.filing_frequency).to eq "some_years"
      expect(diy_intake.source).to eq "source"
      expect(diy_intake.referrer).to eq "referrer"
      expect(diy_intake.visitor_id).to eq "visitor_1"
      expect(diy_intake.locale).to eq "es"
    end
  end
end
