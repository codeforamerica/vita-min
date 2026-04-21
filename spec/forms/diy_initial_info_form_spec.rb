require "rails_helper"

RSpec.describe DiyInitialInfoForm do
  let(:diy_intake) { DiyIntake.new }

  let(:params) do
    {
      preferred_first_name: "Sylvia",
      state_of_residence: "GU",
      zip_code: 96915
    }
  end

  describe "#save" do
    it "saves the right attributes to the record" do
      form = described_class.new(diy_intake, params)
      form.save

      diy_intake.reload
      expect(diy_intake.preferred_first_name).to eq "Sylvia"
      expect(diy_intake.state_of_residence).to eq "GU"
      expect(diy_intake.zip_code).to eq "96915"
    end
  end
end
