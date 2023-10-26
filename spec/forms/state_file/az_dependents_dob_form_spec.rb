require "rails_helper"

RSpec.describe StateFile::AzDependentsDobForm do
  let(:intake) { create :state_file_az_intake }
  let(:first_dependent) { create :state_file_dependent, intake: intake }
  let(:second_dependent) { create :state_file_dependent, intake: intake }

  describe "#save" do
    context "with valid params" do
      let(:valid_params) do
        {
          # dob: Date.parse("August 24, 2015"),
          dependents_attributes: {
            "0": {
              dob_year: 2015,
              dob_day: 24,
              dob_month: 8,
              months_in_home: 8
            }
          }
        }
      end

      it "saves dob and months in home" do
        form = described_class.new(intake, valid_params)
        form.valid?
        form.save

        expect(first_dependent.dob).to eq Date.parse("August 24, 2015")
      end
    end
  end
end
