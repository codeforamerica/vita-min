require "rails_helper"

RSpec.describe StateFile::NyPermanentAddressForm do
  let(:intake) { create :state_file_ny_intake }

  describe "#save" do
    context "address was correct" do
      let(:valid_params) do
        {
          confirmed_permanent_address: "yes",
        }
      end

      it "saves imported_permanent_address_confirmed as true" do
        form = described_class.new(intake, valid_params)
        form.valid?
        form.save

        expect(intake.confirmed_permanent_address).to eq "yes"
      end
    end
  end
end
