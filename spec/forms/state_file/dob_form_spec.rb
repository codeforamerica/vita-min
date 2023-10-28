require "rails_helper"

RSpec.describe StateFile::DobForm do
  let!(:intake) { create :state_file_az_intake, dependents: [create(:state_file_dependent), create(:state_file_dependent)] }
  let!(:first_dependent) { intake.dependents.first }
  let(:second_dependent) { intake.dependents.second }

  describe "#valid?" do
    context "with invalid params" do
      let(:invalid_params) do
        {
          dependents_attributes: {
            "0": {
              id: first_dependent.id,
              dob_year: "2015",
              dob_day: "24",
              dob_month: "8",
              months_in_home: 8
            },
            "1": {
              id: second_dependent.id,
              dob_year: "year",
              dob_day: "day",
              dob_month: "1",
              months_in_home: "10"
            }
          }
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
      end
    end
  end

  describe "#save" do
    context "with valid params" do
      let(:valid_params) do
        {
          dependents_attributes: {
            "0": {
              id: first_dependent.id,
              dob_year: "2015",
              dob_day: "24",
              dob_month: "8",
              months_in_home: "8"
            },
            "1": {
              id: second_dependent.id,
              dob_year: "2013",
              dob_day: "11",
              dob_month: "1",
              months_in_home: "10"
            }
          }
        }
      end

      it "saves dob and months in home" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        form.save

        expect(first_dependent.reload.months_in_home).to eq 8
        expect(first_dependent.reload.dob).to eq Date.parse("August 24, 2015")

        expect(second_dependent.reload.dob).to eq Date.parse("January 11, 2013")
        expect(second_dependent.reload.months_in_home).to eq 10
      end
    end
  end
end
