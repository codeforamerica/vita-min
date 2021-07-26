require "rails_helper"

describe Ctc::SpouseInfoForm do
  let(:intake) { build :ctc_intake }

  let(:params) {
    {
      spouse_first_name: "Madeline",
      spouse_middle_initial: "J",
      spouse_last_name: "Mango",
      spouse_birth_date_year: "1963",
      spouse_birth_date_month: "9",
      spouse_birth_date_day: "10",
      spouse_ssn: "111-22-8888",
      spouse_ssn_confirmation: "111-22-8888",
      spouse_tin_type: 'ssn',
      spouse_active_armed_forces: "no"
    }
  }
  context "validations" do
    context "when all required information is provided" do
      it "is valid" do
        expect(described_class.new(intake, params)).to be_valid
      end
    end
  end

  describe "#existing_attributes" do
    let(:populated_intake) { build :ctc_intake, spouse_birth_date: Date.new(1983, 5, 10), spouse_ssn: "123456789" }

    it "returns a hash with the date fields populated" do
      attributes = Ctc::SpouseInfoForm.existing_attributes(populated_intake)

      expect(attributes[:spouse_birth_date_year]).to eq 1983
      expect(attributes[:spouse_birth_date_month]).to eq 5
      expect(attributes[:spouse_birth_date_day]).to eq 10
      expect(attributes[:spouse_ssn]).to eq "123456789"
      expect(attributes[:spouse_ssn_confirmation]).to eq "123456789"
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
      expect(intake.spouse_birth_date).to eq Date.new(1963, 9, 10)
      expect(intake.spouse_ssn).to eq "111228888"
      expect(intake.spouse_last_four_ssn).to eq "8888"
      expect(intake.spouse_tin_type).to eq "ssn"
      expect(form.intake).to eq intake # resets intake to be the created and persisted intake
    end
  end
end