require "rails_helper"

RSpec.describe StateFile::NyDobForm do
  let!(:intake) { create :state_file_ny_intake, spouse_first_name: "Angelo", dependents: [create(:state_file_dependent), create(:state_file_dependent)] }
  let!(:first_dependent) { intake.dependents.first }
  let(:second_dependent) { intake.dependents.second }

  describe "#save" do
    context "with valid params" do
      let(:valid_params) do
        {
          primary_birth_date_month: "3",
          primary_birth_date_day: "12",
          primary_birth_date_year: "1987",
          spouse_birth_date_month: "5",
          spouse_birth_date_day: "8",
          spouse_birth_date_year: "1986",
          dependents_attributes: {
            "0": {
              id: first_dependent.id,
              dob_year: "2015",
              dob_day: "24",
              dob_month: "8",
            },
            "1": {
              id: second_dependent.id,
              dob_year: "2013",
              dob_day: "11",
              dob_month: "1",
            }
          }
        }
      end

      it "saves dob and months in home" do
        form = described_class.new(intake, valid_params)
        form.save

        expect(intake.reload.primary_birth_date).to eq Date.parse("March 12, 1987")
        expect(intake.reload.spouse_birth_date).to eq Date.parse("May 8, 1986")
        expect(first_dependent.reload.dob).to eq Date.parse("August 24, 2015")
        expect(second_dependent.reload.dob).to eq Date.parse("January 11, 2013")
        expect(form).to be_valid
      end
    end

    context "with invalid birth dates" do
      let(:invalid_params) do
        {
          primary_birth_date_month: "month",
          primary_birth_date_day: "12",
          primary_birth_date_year: "1987",
          spouse_birth_date_month: "5",
          spouse_birth_date_day: "8",
          spouse_birth_date_year: "1986",
          dependents_attributes: {
            "0": {
              id: first_dependent.id,
              dob_year: "2015",
              dob_day: "24",
              dob_month: "8",
            },
            "1": {
              id: second_dependent.id,
              dob_year: "2013",
              dob_day: "11",
              dob_month: "month",
            }
          }
        }
      end

      it "saves valid birth dates but not invalid ones" do
        form = described_class.new(intake, invalid_params)
        form.save

        expect(intake.reload.primary_birth_date).to eq nil
        expect(intake.reload.spouse_birth_date).to eq Date.parse("May 8, 1986")
        expect(first_dependent.reload.dob).to eq Date.parse("August 24, 2015")
        expect(second_dependent.reload.dob).to eq nil
        expect(form).not_to be_valid
      end
    end
  end
end