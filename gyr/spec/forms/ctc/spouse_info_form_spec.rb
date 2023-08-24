require "rails_helper"

describe Ctc::SpouseInfoForm do
  let(:intake) { build :ctc_intake }
  let(:params) {
    {
      spouse_first_name: "Madeline",
      spouse_middle_initial: "J",
      spouse_last_name: "Mango",
      spouse_suffix: "III",
      spouse_birth_date_year: "1963",
      spouse_birth_date_month: "9",
      spouse_birth_date_day: "10",
      spouse_ssn: spouse_ssn,
      spouse_ssn_confirmation: spouse_ssn,
      spouse_tin_type: tin_type,
      ssn_no_employment: ssn_no_employment,
      spouse_active_armed_forces: "no",
      spouse_was_blind: "no"
    }
  }
  let(:spouse_ssn) { "999-78-1224" }
  let(:ssn_no_employment) { "no" }
  let(:tin_type) { "itin" }

  context "initialization with from_intake" do
    let(:intake) { Intake::CtcIntake.new(visitor_id: "something", source: "some-source", spouse_tin_type: "ssn_no_employment") }

    context "coercing tin_type to the correct value when ssn_no_employment" do
      it "sets ssn_no_employment to yes, and spouse_tin_type to ssn" do
        form = described_class.from_intake(intake)
        expect(form.spouse_tin_type).to eq "ssn"
        expect(form.ssn_no_employment).to eq "yes"
      end
    end
  end

  context "validations" do
    context "when all required information is provided" do
      it "is valid" do
        expect(described_class.new(intake, params)).to be_valid
      end
    end

    context "when no ssn is provided" do
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

    context "middle initial" do
      context "when middle initial is not a single letter" do
        before do
          params[:spouse_middle_initial] = '.'
        end

        it "is invalid" do
          expect(described_class.new(intake, params)).not_to be_valid
        end
      end

      context "when middle initial is blank" do
        before do
          params[:spouse_middle_initial] = ''
        end

        it "is invalid" do
          expect(described_class.new(intake, params)).to be_valid
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
      expect(intake.spouse.first_name).to eq "Madeline"
      expect(intake.spouse.middle_initial).to eq "J"
      expect(intake.spouse.last_name).to eq "Mango"
      expect(intake.spouse.suffix).to eq "III"
      expect(intake.spouse.birth_date).to eq Date.new(1963, 9, 10)
      expect(intake.spouse.ssn).to eq "999781224"
      expect(intake.spouse_last_four_ssn).to eq "1224"
      expect(intake.spouse.tin_type).to eq "itin"
      expect(intake.spouse_was_blind).to eq "no"
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
            expect(form.intake.spouse.tin_type).to eq("ssn_no_employment")
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
