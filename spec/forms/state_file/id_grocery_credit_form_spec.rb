require "rails_helper"

RSpec.describe StateFile::IdGroceryCreditForm do
  describe "#valid?" do
    context "without answering the top-level question" do
      let!(:intake) { create :state_file_id_intake, :single_filer_with_json }
      let(:invalid_params) do
        {
          household_has_grocery_credit_ineligible_months: "",
          primary_has_grocery_credit_ineligible_months: "",
          primary_months_ineligible_for_grocery_credit: "",
        }
      end

      it "is invalid and has errors for primary months ineligible" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.errors).to include :household_has_grocery_credit_ineligible_months
      end
    end

    context "without selecting a primary ineligible months number after specifying that primary had ineligible months" do
      let!(:intake) { create :state_file_id_intake, :single_filer_with_json }
      let(:invalid_params) do
        {
          household_has_grocery_credit_ineligible_months: "yes",
          primary_has_grocery_credit_ineligible_months: "yes",
          primary_months_ineligible_for_grocery_credit: "",
        }
      end

      it "is invalid and has errors for primary months ineligible" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.errors).to include :primary_months_ineligible_for_grocery_credit
      end
    end

    context "without selecting a spouse ineligible months number after specifying that spouse had ineligible months" do
      let!(:intake) { create :state_file_id_intake, :mfj_filer_with_json }
      let(:invalid_params) do
        {
          household_has_grocery_credit_ineligible_months: "yes",
          primary_has_grocery_credit_ineligible_months: "no",
          primary_months_ineligible_for_grocery_credit: "",
          spouse_has_grocery_credit_ineligible_months: "yes",
          spouse_months_ineligible_for_grocery_credit: "",
        }
      end

      it "is invalid and has errors for spouse months ineligible" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.errors).to include :spouse_months_ineligible_for_grocery_credit
      end
    end

    context "without selecting a dependent ineligible months number after specifying that dependent had ineligible months" do
      let!(:intake) { create :state_file_id_intake, :with_dependents }
      let(:first_dependent) { intake.dependents[0] }
      let(:second_dependent) { intake.dependents[1] }
      let(:third_dependent) { intake.dependents[2] }
      let(:invalid_params) do
        {
          household_has_grocery_credit_ineligible_months: "yes",
          primary_has_grocery_credit_ineligible_months: "no",
          primary_months_ineligible_for_grocery_credit: "",
          dependents_attributes: {
            '0': {
              id: first_dependent.id,
              id_has_grocery_credit_ineligible_months: "yes"
            },
            '1': {
              id: second_dependent.id,
              id_has_grocery_credit_ineligible_months: "no"
            },
            '2': {
              id: third_dependent.id,
              id_has_grocery_credit_ineligible_months: "no"
            },
            '3': {
              id: first_dependent.id,
              id_months_ineligible_for_grocery_credit: ""
            },
            '4': {
              id: second_dependent.id,
              id_months_ineligible_for_grocery_credit: ""
            },
            '5': {
              id: third_dependent.id,
              id_months_ineligible_for_grocery_credit: ""
            }
          }
        }
      end

      it "is invalid and has errors for dependent months ineligible" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.dependents.first.errors).to include :id_months_ineligible_for_grocery_credit
      end
    end
  end

  describe "#save" do
    context "with valid params" do
      let!(:intake) { create :state_file_id_intake, :with_dependents }
      let(:first_dependent) { intake.dependents[0] }
      let(:second_dependent) { intake.dependents[1] }
      let(:third_dependent) { intake.dependents[2] }

      let(:valid_params) do
        {
          household_has_grocery_credit_ineligible_months: "yes",
          primary_has_grocery_credit_ineligible_months: "yes",
          primary_months_ineligible_for_grocery_credit: 5,
          dependents_attributes: {
            '0': {
              id: first_dependent.id,
              id_has_grocery_credit_ineligible_months: "yes"
            },
            '1': {
              id: second_dependent.id,
              id_has_grocery_credit_ineligible_months: "no"
            },
            '2': {
              id: third_dependent.id,
              id_has_grocery_credit_ineligible_months: "no"
            },
            '3': {
              id: first_dependent.id,
              id_months_ineligible_for_grocery_credit: 3
            },
            '4': {
              id: second_dependent.id,
              id_months_ineligible_for_grocery_credit: ""
            },
            '5': {
              id: third_dependent.id,
              id_months_ineligible_for_grocery_credit: ""
            }
          }
        }
      end

      it "saves successfully" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        form.save

        expect(intake.household_has_grocery_credit_ineligible_months).to eq("yes")
        expect(intake.primary_has_grocery_credit_ineligible_months).to eq("yes")
        expect(intake.primary_months_ineligible_for_grocery_credit).to eq(5)
        expect(intake.spouse_has_grocery_credit_ineligible_months).to eq("unfilled")
        expect(intake.spouse_months_ineligible_for_grocery_credit).to eq(0)

        expect(first_dependent.id_has_grocery_credit_ineligible_months).to eq("yes")
        expect(first_dependent.id_months_ineligible_for_grocery_credit).to eq(3)
        expect(second_dependent.id_has_grocery_credit_ineligible_months).to eq("no")
        expect(second_dependent.id_months_ineligible_for_grocery_credit).to eq(nil)
        expect(third_dependent.id_has_grocery_credit_ineligible_months).to eq("no")
        expect(third_dependent.id_months_ineligible_for_grocery_credit).to eq(nil)
      end
    end
  end
end