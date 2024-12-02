require "rails_helper"

RSpec.describe StateFile::IncomeReviewForm do
  let!(:intake) { create :state_file_az_intake }
  let!(:efile_device_info) { create :state_file_efile_device_info, :initial_creation, intake: intake, device_id: nil }
  let(:device_id) { "AA" * 20 }
  let(:params) do
    {
      device_id: device_id,
    }
  end

  describe "#save" do
    it "saves the device id" do
      form = described_class.new(intake, params)
      expect(form).to be_valid
      form.save

      intake.reload
      expect(intake.initial_efile_device_info.device_id).to eq device_id
    end
  end
end
