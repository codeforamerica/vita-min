require "rails_helper"

describe Ctc::SpouseDriversLicenseForm do
  let(:form) { described_class.new(intake, params) }
  let(:intake) { build :ctc_intake }
  let(:params) {
    {
      issue_date_year: "2020",
      issue_date_month: "9",
      issue_date_day: "10",
      expiration_date_year: "2024",
      expiration_date_month: "9",
      expiration_date_day: "10",
      state: "CA",
      license_number: "YT12345",
    }
  }

  context "validations" do
    context "when all required information is provided" do
      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when there is no valid issue date or expiration date" do
      let(:params) {
        {
          issue_date_year: "0000",
          issue_date_month: "0",
          issue_date_day: "00",
          expiration_date_year: nil,
          expiration_date_month: nil,
          expiration_date_day: nil,
          state: "CA",
          license_number: "YT12345",
        }
      }

      it "includes the correct error attributes" do
        form.valid?
        expect(form.errors.attribute_names).to include :issue_date, :expiration_date
      end
    end

    context "license number" do
      context "not allowed characters: supertext" do
        before do
          params[:license_number] = "101619702¹1"
        end

        it "is not valid" do
          form.valid?
          expect(form.errors.attribute_names).to include :license_number
        end
      end
    end
  end

  describe "#existing_attributes" do
    let(:populated_intake) { build :ctc_intake, spouse_drivers_license: create(:drivers_license, issue_date: Date.new(2020, 5, 10), expiration_date: Date.new(2022, 5, 10)) }

    it "returns a hash with the date fields populated" do
      attributes = Ctc::SpouseDriversLicenseForm.existing_attributes(populated_intake, Ctc::SpouseDriversLicenseForm.scoped_attributes[:intake])

      expect(attributes[:issue_date_year]).to eq 2020
      expect(attributes[:issue_date_month]).to eq 5
      expect(attributes[:issue_date_day]).to eq 10
      expect(attributes[:expiration_date_year]).to eq 2022
      expect(attributes[:expiration_date_month]).to eq 5
      expect(attributes[:expiration_date_day]).to eq 10
    end
  end

  describe "#save" do
    it "saves the attributes on a drivers license associated with intake" do
      form = described_class.new(intake, params)
      form.valid?
      expect(form.save).to be_truthy

      drivers_license = Intake.last.spouse_drivers_license
      expect(drivers_license.state).to eq "CA"
      expect(drivers_license.license_number).to eq "YT12345"
      expect(drivers_license.issue_date).to eq Date.new(2020, 9, 10)
      expect(drivers_license.expiration_date).to eq Date.new(2024, 9, 10)
    end
  end
end
