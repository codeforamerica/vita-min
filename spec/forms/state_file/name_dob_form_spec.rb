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

  describe "#valid?" do
    context "without a primary first name or last name" do
      let(:intake) { build(:state_file_az_intake) }
      let(:params) do
        {
          primary_first_name: "",
          primary_last_name: ""
        }
      end

      it "is not valid and adds errors to missing fields" do
        form = described_class.new(intake, params)

        expect(form).not_to be_valid
        expect(form.errors).to include :primary_first_name
        expect(form.errors).to include :primary_last_name
      end
    end

    context "when filing jointly and missing spouse first or last name" do
      let(:intake) { build(:state_file_az_intake) }
      let(:params) do
        {
          primary_first_name: "Tornelius",
          primary_last_name: "Testofferson",
          spouse_first_name: "",
          spouse_last_name: ""
        }
      end
      before { allow(intake).to receive_messages(filing_status_mfj?: true) }

      it "is not valid and puts errors on the appropriate fields" do
        form = described_class.new(intake, params)

        expect(form).not_to be_valid
        expect(form.errors).to include :spouse_first_name
        expect(form.errors).to include :spouse_last_name
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
    context "when primary dob is required" do
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
        expect(second_dependent.dob).to eq Date.parse("January 11, 2013")
        expect(second_dependent.months_in_home).to eq 10
      end
    end

    context "when primary dob is optional" do
      context "with valid params" do
        let(:valid_params) do
          {
            primary_first_name: "Taliesen",
            primary_last_name: "Testingson",
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

        it "saves names, dobs, and months in home" do
          form = described_class.new(intake, valid_params)
          expect(form).to be_valid
          form.save

          first_dependent.reload
          second_dependent.reload

          expect(first_dependent.first_name).to eq "Tessa"
          expect(first_dependent.last_name).to eq "Testofferson"
          expect(first_dependent.months_in_home).to eq 8
          expect(first_dependent.dob).to eq Date.parse("August 24, 2015")


          expect(second_dependent.first_name).to eq "Teague"
          expect(second_dependent.last_name).to eq "Testingson"
          expect(second_dependent.dob).to eq Date.parse("January 11, 2013")
          expect(second_dependent.months_in_home).to eq 10
        end
      end
    end
  end
end
