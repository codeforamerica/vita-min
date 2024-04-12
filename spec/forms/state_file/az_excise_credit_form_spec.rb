require "rails_helper"

RSpec.describe StateFile::AzExciseCreditForm do
  let!(:intake) { create :state_file_az_intake }

  describe "#valid?" do
    context "incarceration field(s)" do
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
          form = described_class.new(intake, {
            primary_was_incarcerated: nil,
            ssn_no_employment: "yes",
            household_excise_credit_claimed: "no"
          })
          expect(form).not_to be_valid
          expect(form.errors).to include :primary_was_incarcerated

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
    end

    context "excise credit claimed" do
      it "requires credit amount when credit claimed" do
        invalid_params = {
          primary_was_incarcerated: "no",
          ssn_no_employment: "yes",
          household_excise_credit_claimed: "yes"
        }
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.errors).to include :household_excise_credit_claimed_amt

        valid_params = {
          primary_was_incarcerated: "no",
          ssn_no_employment: "yes",
          household_excise_credit_claimed: "yes",
          household_excise_credit_claimed_amt: 1000
        }
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        expect(form.errors).to be_empty
      end

      it "requires credit amount to be a positive integer" do
        invalid_params_zero = {
          primary_was_incarcerated: "no",
          ssn_no_employment: "yes",
          household_excise_credit_claimed: "yes",
          household_excise_credit_claimed_amt: 0
        }
        form = described_class.new(intake, invalid_params_zero)
        expect(form).not_to be_valid
        expect(form.errors).to include :household_excise_credit_claimed_amt

        invalid_params_float = {
          primary_was_incarcerated: "no",
          ssn_no_employment: "yes",
          household_excise_credit_claimed: "yes",
          household_excise_credit_claimed_amt: 500.23
        }
        form = described_class.new(intake, invalid_params_float)
        expect(form).not_to be_valid
        expect(form.errors).to include :household_excise_credit_claimed_amt
      end
    end
  end

  describe "#save" do
    context "when params are valid" do
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

      it "zeroes out credit amount if credit claimed = no (does not save the amount param if claimed = no)" do
        intake.update(household_excise_credit_claimed_amt: 2000)

        form = described_class.new(intake, {
          primary_was_incarcerated: "yes",
          ssn_no_employment: "yes",
          household_excise_credit_claimed: "no",
          household_excise_credit_claimed_amt: 1000
        })
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.primary_was_incarcerated_yes?).to eq true
        expect(intake.ssn_no_employment_yes?).to eq true
        expect(intake.household_excise_credit_claimed_no?).to eq true
        expect(intake.household_excise_credit_claimed_amt).to be_nil
      end
    end
  end
end