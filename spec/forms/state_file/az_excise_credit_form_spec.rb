require "rails_helper"

RSpec.describe StateFile::AzExciseCreditForm do
  let!(:intake) { create :state_file_az_intake }

  describe "#valid?" do
    context "TEMPORARY" do
      it "accepts old params" do
        form = described_class.new(intake, {
          was_incarcerated: "yes",
          ssn_no_employment: "yes",
          household_excise_credit_claimed: "yes"
        })
        expect(form).to be_valid
        expect(form.errors).to be_empty
      end
    end

    let(:single_filer_params) {
      {
        primary_was_incarcerated: "yes",
        ssn_no_employment: "yes",
        household_excise_credit_claimed: "no"
      }
    }
    let(:mfj_params) {
      {
        primary_was_incarcerated: "no",
        spouse_was_incarcerated: "yes",
        ssn_no_employment: "yes",
        household_excise_credit_claimed: "no"
      }
    }

    context "single filer" do
      it "only needs field for primary" do
        form = described_class.new(intake, single_filer_params)
        expect(form).to be_valid
        expect(form.errors).to be_empty
      end
    end

    context "mfj filers" do
      before do
        intake.direct_file_data.filing_status = 2
      end

      it "does not accept fields for only primary" do
        form = described_class.new(intake, single_filer_params)
        expect(form).not_to be_valid
        expect(form.errors).to include :spouse_was_incarcerated
      end

      it "accepts fields for primary and spouse" do
        form = described_class.new(intake, mfj_params)
        expect(form).to be_valid
        expect(form.errors).to be_empty
      end
    end

    context "excise credit" do
      let(:invalid_params) {
        {
          primary_was_incarcerated: "yes",
          ssn_no_employment: "yes",
          household_excise_credit_claimed: "yes"
        }
      }
      let(:valid_params) {
        {
          primary_was_incarcerated: "yes",
          ssn_no_employment: "yes",
          household_excise_credit_claimed: "yes",
          household_excise_credit_claimed_amt: 1000
        }
      }

      it "requires credit amount when credit claimed" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.errors).to include :household_excise_credit_claimed_amt

        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        expect(form.errors).to be_empty
      end
    end
  end

  describe "#save" do
    context "when params are valid" do
      it "TEMPORARY saves old values" do
        form = described_class.new(intake, {
          was_incarcerated: "yes",
          ssn_no_employment: "yes",
          household_excise_credit_claimed: "yes"
        })
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.was_incarcerated_yes?).to eq true
        expect(intake.ssn_no_employment_yes?).to eq true
        expect(intake.household_excise_credit_claimed_yes?).to eq true
      end

      it "saves values" do
        form = described_class.new(intake, {
          primary_was_incarcerated: "yes",
          ssn_no_employment: "yes",
          household_excise_credit_claimed: "yes",
          household_excise_credit_claimed_amt: 1000
        })
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.primary_was_incarcerated_yes?).to eq true
        expect(intake.ssn_no_employment_yes?).to eq true
        expect(intake.household_excise_credit_claimed_yes?).to eq true
        expect(intake.household_excise_credit_claimed_amt).to eq 1000
      end
    end
  end
end