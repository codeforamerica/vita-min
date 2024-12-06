require 'rails_helper'

RSpec.describe StateFile::NcCountyForm, type: :model do

  describe "simple validations" do
    it { should validate_presence_of :residence_county}
    it { should validate_inclusion_of(:residence_county).in_array(StateFileNcIntake::COUNTIES.keys) }
  end

  describe "#save" do
    it "should assign residence_county to intake" do
      intake = create(:state_file_nc_intake)

      form = StateFile::NcCountyForm.from_intake(intake)

      form.residence_county = "002"

      expect { form.save }.to change(intake, :residence_county).to("002")
    end
  end

  # add validations
end
