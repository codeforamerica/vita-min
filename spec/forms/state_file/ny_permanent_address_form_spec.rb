require "rails_helper"

RSpec.describe StateFile::NyPermanentAddressForm do
  let(:intake) { create :state_file_ny_intake,
                        permanent_apartment: nil,
                        permanent_city: nil,
                        permanent_street: nil,
                        permanent_zip: nil
  }

  describe "validations" do
    context "invalid params" do
      context "they answered yes but included a new address" do

      end

      context "they answered no but did not include a new address" do

      end
    end
  end

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
      let(:permanent_apartment) { "B" }
      let(:permanent_street) { "132 Peanut Way" }
      let(:permanent_city) { "New York" }
      let(:permanent_zip) { "11102" }
      let(:valid_params) do
        {
          confirmed_permanent_address: "no",
          permanent_apartment: permanent_apartment,
          permanent_street: permanent_street,
          permanent_city: permanent_city,
          permanent_zip: permanent_zip,
        }
      end

      it "saves imported_permanent_address_confirmed as true" do
        form = described_class.new(intake, valid_params)
        form.valid?
        form.save

        expect(intake.confirmed_permanent_address).to eq "no"
        expect(intake.permanent_apartment).to permanent_apartment
        expect(intake.permanent_street).to permanent_street
        expect(intake.permanent_city).to permanent_city
        expect(intake.permanent_zip).to permanent_zip
      end
    end
  end
end
