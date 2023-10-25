require "rails_helper"

RSpec.describe StateFile::NyPermanentAddressForm do
  let(:intake) { StateFileNyIntake.new }

  describe "#save" do
    context "address was correct" do
      let(:valid_params) do
        {
          imported_permanent_address_confirmed: true,
        }
      end

      it "saves imported_permanent_address_confirmed as true" do
        form = described_class.new(intake, valid_params)
        form.valid?
        form.save

        expect(intake.imported_permanent_address_confirmed).to eq true
      end
    end
  end
end
