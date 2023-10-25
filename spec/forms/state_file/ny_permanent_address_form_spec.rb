require "rails_helper"

RSpec.describe StateFile::NyPermanentAddressForm do
  let(:intake) { create :state_file_ny_intake,
                        permanent_apartment: nil,
                        permanent_city: nil,
                        permanent_street: nil,
                        permanent_zip: nil
  }

  describe "#save" do
    context "they say yes (mailing address is confirmed as permanent address)" do
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
        expect(intake.permanent_apartment).to eq intake.direct_file_data.mailing_apartment
        expect(intake.permanent_street).to eq intake.direct_file_data.mailing_street
        expect(intake.permanent_city).to eq intake.direct_file_data.mailing_city
        expect(intake.permanent_zip).to eq intake.direct_file_data.mailing_zip
      end
    end

    context "they say no (mailing address not the same as permanent address)" do
      let(:valid_params) do
        {
          confirmed_permanent_address: "no",
        }
      end

      it "saves imported_permanent_address_confirmed as true" do
        form = described_class.new(intake, valid_params)
        form.valid?
        form.save

        expect(intake.confirmed_permanent_address).to eq "no"
        expect(intake.permanent_apartment).to be_nil
        expect(intake.permanent_street).to be_nil
        expect(intake.permanent_city).to be_nil
        expect(intake.permanent_zip).to be_nil
      end
    end
  end
end
