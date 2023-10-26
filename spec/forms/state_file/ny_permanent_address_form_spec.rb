require "rails_helper"

RSpec.describe StateFile::NyPermanentAddressForm do
  let(:intake) { create :state_file_ny_intake,
                        permanent_apartment: nil,
                        permanent_city: nil,
                        permanent_street: nil,
                        permanent_zip: nil
  }

  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }

    context "invalid params" do
      context "confirmation of address is required" do
        let(:invalid_params) do
          {
            confirmed_permanent_address: nil,
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false

          expect(form.errors[:confirmed_permanent_address]).to include "Can't be blank."
        end
      end

      context "they answered no but did not include required address fields" do
        let(:invalid_params) do
          {
            confirmed_permanent_address: "no",
            permanent_apartment: nil,
            permanent_city: nil,
            permanent_street: nil,
            permanent_zip: nil
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:permanent_city]).to include "Can't be blank."
          expect(form.errors[:permanent_street]).to include "Can't be blank."
          expect(form.errors[:permanent_zip]).to include "Can't be blank."
        end
      end
    end
  end

  describe "#save" do
    let(:form) { described_class.new(intake, valid_params) }

    context "they say yes (mailing address is confirmed as permanent address)" do
      let(:valid_params) do
        {
          confirmed_permanent_address: "yes",
        }
      end

      it "saves imported_permanent_address_confirmed as true" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.confirmed_permanent_address).to eq "yes"
        expect(intake.permanent_apartment).to eq intake.direct_file_data.mailing_apartment
        expect(intake.permanent_street).to eq intake.direct_file_data.mailing_street
        expect(intake.permanent_city).to eq intake.direct_file_data.mailing_city
        expect(intake.permanent_zip).to eq intake.direct_file_data.mailing_zip
      end

      context "intake already has permanent address fields saved" do
        let(:intake) { create :state_file_ny_intake,
                              permanent_apartment: "X",
                              permanent_city: "No York",
                              permanent_street: "123 Throwa Way",
                              permanent_zip: "00000"
        }

        it "overwrites with address fields from 1040" do
          expect(form.valid?).to eq true
          form.save

          expect(intake.confirmed_permanent_address).to eq "yes"
          expect(intake.permanent_apartment).to eq intake.direct_file_data.mailing_apartment
          expect(intake.permanent_street).to eq intake.direct_file_data.mailing_street
          expect(intake.permanent_city).to eq intake.direct_file_data.mailing_city
          expect(intake.permanent_zip).to eq intake.direct_file_data.mailing_zip
        end
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
        expect(form.valid?).to eq true
        form.save

        expect(intake.confirmed_permanent_address).to eq "no"
        expect(intake.permanent_apartment).to eq permanent_apartment
        expect(intake.permanent_street).to eq permanent_street
        expect(intake.permanent_city).to eq permanent_city
        expect(intake.permanent_zip).to eq permanent_zip
      end
    end
  end
end
