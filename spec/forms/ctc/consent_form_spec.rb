require "rails_helper"

describe Ctc::ConsentForm do
  let(:intake) { Intake::CtcIntake.new(visitor_id: "something") }

  context "validations" do
    let(:params) {
      {
        primary_first_name: "Marty",
        primary_middle_initial: "J",
        primary_last_name: "Mango",
        primary_birth_date_year: "1963",
        primary_birth_date_month: "9",
        primary_birth_date_day: "10",
        primary_ssn: "111-22-8888",
        primary_ssn_confirmation: "111-22-8888",
        phone_number: "831-234-5678",
        timezone: "America/Chicago",
        tin_type: :ssn
      }
    }
    context "when all required information is provided" do
      it "is valid" do
        expect(described_class.new(intake, params)).to be_valid
      end
    end

    context "when first name is not provided" do
      before do
        params[:primary_first_name] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when last name is not provided" do
      before do
        params[:primary_last_name] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when ssn does not match confirmation" do
      before do
        params[:primary_ssn_confirmation] = "222-44-8888"
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when ssn is not confirmed" do
      before do
        params[:primary_ssn_confirmation] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when phone number is not valid" do
      before do
        params[:phone_number] = "555-123-4567"
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when phone number is not present" do
      before do
        params[:phone_number] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when the birth date is missing a number" do
      before do
        params[:primary_birth_date_month] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when the birth date is not a valid date" do
      before do
        params[:primary_birth_date_month] = "14"
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end
  end

  describe "#save" do
    it "saves the attributes on the intake and creates a client and 2020 tax return" do
      form = described_class.new(intake, {
          primary_first_name: "Marty",
          primary_middle_initial: "J",
          primary_last_name: "Mango",
          primary_birth_date_year: "1963",
          primary_birth_date_month: "9",
          primary_birth_date_day: "10",
          primary_ssn: "111-22-8888",
          primary_ssn_confirmation: "111-22-8888",
          phone_number: "831-234-5678",
          timezone: "America/Chicago",
          tin_type: :itin
      })
      expect {
        form.valid? # the form only transforms the phone number if it is validated before calling save
        form.save
      }.to change(Client, :count).by(1).and change(TaxReturn, :count).by(1)
      intake = Intake.last
      expect(intake.primary_first_name).to eq "Marty"
      expect(intake.primary_middle_initial).to eq "J"
      expect(intake.primary_last_name).to eq "Mango"
      expect(intake.primary_birth_date).to eq Date.new(1963, 9, 10)
      expect(intake.primary_ssn).to eq "111228888"
      expect(intake.phone_number).to eq "+18312345678"
      expect(intake.primary_last_four_ssn).to eq "8888"
      expect(intake.timezone).to eq "America/Chicago"
      expect(intake.client).to be_present
      expect(intake.tax_returns.length).to eq 1
      expect(intake.tax_returns.first.year).to eq 2020
      expect(intake.tax_returns.first.is_ctc).to eq true
      expect(intake.tin_type).to eq "itin"
      expect(intake.type).to eq "Intake::CtcIntake"
      expect(form.intake).to eq intake # resets intake to be the created and persisted intake
    end
  end
end