require "rails_helper"

describe Ctc::SpouseInfoForm do
  let(:intake) { build :ctc_intake }
  let(:params) {
    {
      issue_date_year: "2020",
      issue_date_month: "9",
      issue_date_day: "10",
      expiration_date_year: "2024",
      expiration_date_month: "9",
      expiration_date_day: "10",
      state: "CA",
      license_number: "YT12345",
    }
  }

  context "validations" do
    context "when all required information is provided" do
      it "is valid" do
        expect(described_class.new(intake, params)).to be_valid
      end
    end

    context "when no issue date" do
      let(:tin_type) { "ssn" }
      let(:spouse_ssn) { "" }
      it "is invalid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end

      context "when the ssn_no_employment checkbox is yes" do
        let(:ssn_no_employment) { "yes" }
        it "still requires ssn to be present" do
          expect(described_class.new(intake, params)).not_to be_valid
        end
      end
    end
  end

  describe "#existing_attributes" do
    let(:populated_intake) { build :ctc_intake, spouse_birth_date: Date.new(1983, 5, 10), spouse_ssn: "123456789" }

    it "returns a hash with the date fields populated" do
      attributes = Ctc::SpouseInfoForm.existing_attributes(populated_intake, Ctc::SpouseInfoForm.scoped_attributes[:intake])

      expect(attributes[:spouse_birth_date_year]).to eq 1983
      expect(attributes[:spouse_birth_date_month]).to eq 5
      expect(attributes[:spouse_birth_date_day]).to eq 10
      expect(attributes[:spouse_ssn]).to eq "123456789"
    end
  end

  describe "#save" do
    it "saves the attributes on the intake and creates a client and 2020 tax return" do
      form = described_class.new(intake, params)
      form.valid? # the form only transforms the phone number if it is validated before calling save
      expect(form.save).to be_truthy

      intake = Intake.last
      expect(intake.spouse_first_name).to eq "Madeline"
      expect(intake.spouse_middle_initial).to eq "J"
      expect(intake.spouse_last_name).to eq "Mango"
      expect(intake.spouse_suffix).to eq "III"
      expect(intake.spouse_birth_date).to eq Date.new(1963, 9, 10)
      expect(intake.spouse_ssn).to eq "999781224"
      expect(intake.spouse_last_four_ssn).to eq "1224"
      expect(intake.spouse_tin_type).to eq "itin"
      expect(intake.spouse_can_be_claimed_as_dependent).to eq "no"
      expect(form.intake).to eq intake # resets intake to be the created and persisted intake
    end

    context "tin types" do
      context "when tin type is ssn" do
        let(:tin_type) { "ssn" }
        context "when the ssn_no_employment checkbox is value yes" do
          let(:ssn_no_employment) { "yes" }

          it "has a resulting tin type of ssn_no_employment" do
            form = described_class.new(intake, params)
            form.valid?
            form.save
            form.intake.spouse_tin_type = "ssn_no_employment"
          end
        end

        context "when the ssn_no_employment checkbox value is no" do
          let(:ssn_no_employment) { "no" }

          it "has a resulting tin type of ssn" do
            form = described_class.new(intake, params)
            form.valid?
            form.save
            Intake.last.spouse_tin_type = "ssn"
          end
        end
      end

      context "when tin type is not ssn" do
        let(:ssn_no_employment) { "no" }
        let(:tin_type) { "itin" }

        it "sets the tin type to itin" do
          form = described_class.new(intake, params)
          form.valid?
          form.save
          Intake.last.spouse_tin_type = "itin"
        end
      end
    end
  end
end
