require "rails_helper"

RSpec.describe SpouseConsentForm do
  let(:intake) { create :intake }
  let(:default_params) do
    {
      spouse_consented_to_service_ip: "123.1.2.7",
    }
  end
  let(:valid_params) do
    default_params.merge(
      {
        birth_date_year: "1983",
        birth_date_month: "5",
        birth_date_day: "10",
        spouse_first_name: "Greta",
        spouse_last_name: "Gnome",
        spouse_tin_type: "ssn",
        spouse_ssn: "123456789",
        spouse_ssn_confirmation: "123456789"
      }
    )
  end

  describe "validations" do
    context "when all params are valid" do
      it "is valid" do
        form = SpouseConsentForm.new(intake, valid_params)

        expect(form).to be_valid
      end
    end

    context "required params are missing" do
      it "adds errors for each" do
        form = SpouseConsentForm.new(
          intake,
          default_params.merge(
            {
              birth_date_year: "1983",
              birth_date_month: nil,
              birth_date_day: "10",
              spouse_first_name: "Greta",
              spouse_last_name: nil,
              spouse_ssn: nil,
              spouse_tin_type: nil
            }
          )
        )

        expect(form).not_to be_valid
        expect(form.errors[:birth_date]).to be_present
        expect(form.errors[:spouse_last_name]).to be_present
        expect(form.errors[:spouse_ssn]).to be_present
        expect(form.errors[:spouse_tin_type]).to be_present
      end
    end

    context "with a spouse_ssn that is too short" do
      let(:params) { valid_params.merge(spouse_ssn: "765") }

      it "adds a validation error" do
        form = SpouseConsentForm.new(intake, params)

        expect(form).not_to be_valid
        expect(form.errors[:spouse_ssn]).to be_present
      end
    end

    context "with a spouse_ssn that is too long" do
      let(:params) { valid_params.merge(spouse_ssn: "765123123123123123123123") }

      it "adds a validation error" do
        form = SpouseConsentForm.new(intake, params)

        expect(form).not_to be_valid
        expect(form.errors[:spouse_ssn]).to be_present
      end
    end

    context "when ssn_no_employment is yes and tin_type is ssn" do
      let(:params) { valid_params.merge(spouse_tin_type: "ssn", ssn_no_employment: "yes") }

      it "persists tin_type as ssn_no_employment" do
        form = SpouseConsentForm.new(intake, params)
        form.valid?
        form.save

        expect(form.intake.reload.spouse_tin_type).to eq "ssn_no_employment"
      end
    end

    context "when the date is not valid" do
      let(:params) { valid_params.merge(birth_date_month: "2", birth_date_day: "31") }

      it "adds a validation error" do
        form = SpouseConsentForm.new(intake, params)

        expect(form).not_to be_valid
        expect(form.errors[:birth_date]).to be_present
        expect(form.errors[:birth_date]).to include "Please select a valid date"
      end
    end
  end

  describe "#save" do
    before do
      allow(DateTime).to receive(:now).and_return DateTime.new(2025, 2, 7, 11, 10, 1)
    end

    it "parses & saves the correct data to the model record" do
      form = SpouseConsentForm.new(intake, valid_params)
      form.save
      intake.reload

      expect(intake.spouse_birth_date).to eq Date.new(1983, 5, 10)
      expect(intake.spouse_consented_to_service).to eq "yes"
      expect(intake.spouse_consented_to_service_at).to eq DateTime.new(2025, 2, 7, 11, 10, 1)
    end
  end

  describe "#existing_attributes" do
    let(:populated_intake) { build :intake, spouse_birth_date: Date.new(1983, 5, 10) }

    it "returns a hash with the date fields populated" do
      attributes = SpouseConsentForm.existing_attributes(populated_intake)

      expect(attributes[:birth_date_year]).to eq 1983
      expect(attributes[:birth_date_month]).to eq 5
      expect(attributes[:birth_date_day]).to eq 10
    end
  end
end