require "rails_helper"

RSpec.describe StateFile::NameDobForm do
  let!(:intake) { create :state_file_az_intake, dependents: [create(:state_file_dependent), create(:state_file_dependent)] }
  let!(:first_dependent) { intake.dependents.first }
  let(:second_dependent) { intake.dependents.second }
  let(:valid_params) do
    {
      primary_first_name: "Taliesen",
      primary_last_name: "Testingson",
      primary_birth_date_month: "3",
      primary_birth_date_day: "12",
      primary_birth_date_year: "1987",
      spouse_first_name: "Tiberius",
      spouse_last_name: "Testofferson",
      spouse_birth_date_month: "5",
      spouse_birth_date_day: "8",
      spouse_birth_date_year: "1986",
      dependents_attributes: {
        "0": {
          id: first_dependent.id,
          first_name: "Tessa",
          last_name: "Testofferson",
          dob_year: "2015",
          dob_day: "24",
          dob_month: "8",
          months_in_home: "8"
        },
        "1": {
          id: second_dependent.id,
          first_name: "Teague",
          last_name: "Testingson",
          dob_year: "2013",
          dob_day: "11",
          dob_month: "1",
          months_in_home: "10"
        }
      }
    }
  end

  def params_with_values_from_intake(params, intake)
    params[:dependents_attributes][:"0"][:months_in_home] = intake.dependents[0].months_in_home
    params[:dependents_attributes][:"1"][:months_in_home] = intake.dependents[1].months_in_home
    params
  end

  describe "#valid?" do
    context "without a primary first name or last name or dob" do
      let(:intake) { build(:state_file_az_intake) }
      let(:params) do
        {
          primary_first_name: "",
          primary_last_name: "",
          primary_birth_date_month: "",
          primary_birth_date_day: "",
          primary_birth_date_year: ""
        }
      end

      it "is not valid and adds errors to missing fields" do
        form = described_class.new(intake, params)

        expect(form).not_to be_valid
        expect(form.errors).to include :primary_first_name
        expect(form.errors).to include :primary_last_name
        expect(form.errors).to include :primary_birth_date
      end
    end

    context "when filing jointly and missing spouse first or last name or dob" do
      let(:intake) { build(:state_file_az_intake) }
      let(:params) do
        {
          primary_first_name: "Tornelius",
          primary_last_name: "Testofferson",
          spouse_first_name: "",
          spouse_last_name: "",
          spouse_birth_date_month: "",
          spouse_birth_date_day: "",
          spouse_birth_date_year: ""
        }
      end
      before { allow(intake).to receive_messages(filing_status_mfj?: true) }

      it "is not valid and puts errors on the appropriate fields" do
        form = described_class.new(intake, params)

        expect(form).not_to be_valid
        expect(form.errors).to include :spouse_first_name
        expect(form.errors).to include :spouse_last_name
        expect(form.errors).to include :spouse_birth_date
      end
    end

    context "with missing dependent name or a piece of dob" do
      let(:invalid_params) do
        {
          dependents_attributes: {
            "0": {
              id: first_dependent.id,
              first_name: "Tessa",
              last_name: "Testofferson",
              dob_year: "2015",
              dob_day: "24",
              dob_month: "8",
              months_in_home: 8
            },
            "1": {
              id: second_dependent.id,
              first_name: "",
              last_name: "",
              dob_year: "year",
              dob_day: "day",
              dob_month: "1",
              months_in_home: "10"
            }
          }
        }
      end

      it "returns false and adds the correct errors" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.dependents.second.errors).to include(:first_name)
        expect(form.dependents.second.errors).to include(:last_name)
        expect(form.dependents.second.errors).to include(:dob)
      end
    end
  end

  describe "#save" do
    context "saving all the params (particularly dates)" do
      let!(:intake) { create :state_file_ny_intake, filing_status: 'married_filing_jointly', dependents: [create(:state_file_dependent), create(:state_file_dependent)] }

      it "saves names, dobs, and months in home" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.primary_birth_date).to eq Date.parse("March 12, 1987")
        expect(intake.primary_first_name).to eq "Taliesen"
        expect(intake.primary_last_name).to eq "Testingson"
        expect(intake.spouse_birth_date).to eq Date.parse("May 8, 1986")
        expect(intake.spouse_first_name).to eq "Tiberius"
        expect(intake.spouse_last_name).to eq "Testofferson"

        first_dependent.reload
        second_dependent.reload

        expect(first_dependent.first_name).to eq "Tessa"
        expect(first_dependent.last_name).to eq "Testofferson"
        expect(first_dependent.months_in_home).to eq 8
        expect(first_dependent.dob).to eq Date.parse("August 24, 2015")

        expect(second_dependent.first_name).to eq "Teague"
        expect(second_dependent.last_name).to eq "Testingson"
        expect(second_dependent.months_in_home).to eq 10
        expect(second_dependent.dob).to eq Date.parse("January 11, 2013")
      end
    end

    context "when married filing separately in new york" do
      let!(:intake) { create :state_file_ny_intake, filing_status: "married_filing_separately" }

      context "with valid params" do
        let(:valid_params) do
          {
            primary_first_name: "Taliesen",
            primary_last_name: "Testingson",
            primary_birth_date_month: "3",
            primary_birth_date_day: "12",
            primary_birth_date_year: "1987",
          }
        end

        it "saves primary name" do
          form = described_class.new(intake, valid_params)
          expect(form).to be_valid
          form.save
        end
      end
    end

    context "when the federal return does not have an hoh qualifying person" do
      context "when the filer is head of household" do

        context "when there is a dependent with a non-NONE relationship and 6 or more months in home" do
          let!(:intake) { create :state_file_az_intake, filing_status: 'head_of_household', dependents: [create(:az_hoh_qualifying_person_nonparent), create(:az_hoh_nonqualifying_person_nonparent)] }

          it "is valid" do
            form = described_class.new(intake, params_with_values_from_intake(valid_params, intake))
            expect(form).to be_valid
          end
        end

        context "when there is a PARENT dependent with any number of months in home" do
          let!(:intake) { create :state_file_az_intake, filing_status: 'head_of_household', dependents: [create(:az_hoh_qualifying_person_parent), create(:az_hoh_nonqualifying_person_nonparent)] }

          it "is valid" do
            form = described_class.new(intake, params_with_values_from_intake(valid_params, intake))
            expect(form).to be_valid
          end
        end

        context "when dependents are all non-PARENT relationship type or fewer than 6 months in home" do
          let!(:intake) { create :state_file_az_intake, filing_status: 'head_of_household', dependents: [create(:az_hoh_nonqualifying_person_nonparent), create(:az_hoh_nonqualifying_person_none_relationship)] }

          it "is not valid" do
            form = described_class.new(intake, params_with_values_from_intake(valid_params, intake))
            expect(form).not_to be_valid
            expect(form.errors[:hoh_qualifying_person_name]).to be_present
          end
        end
      end

      context "when the filer is qualifying surviving spouse/qualifying widow without a valid household member" do
        let!(:intake) { create :state_file_az_intake, filing_status: "5", dependents: [create(:az_hoh_nonqualifying_person_nonparent), create(:az_hoh_nonqualifying_person_none_relationship)] }

        it "is not valid" do
          form = described_class.new(intake, params_with_values_from_intake(valid_params, intake))
          expect(form).not_to be_valid
          expect(form.errors[:hoh_qualifying_person_name]).to be_present
        end
      end

      context "when the filer is not HOH or QSS without a valid household member" do
        let!(:intake) { create :state_file_az_intake, filing_status: "1", dependents: [create(:az_hoh_nonqualifying_person_nonparent), create(:az_hoh_nonqualifying_person_none_relationship)] }

        it "is valid" do
          form = described_class.new(intake, params_with_values_from_intake(valid_params, intake))
          expect(form).to be_valid
        end
      end
    end
  end
end
