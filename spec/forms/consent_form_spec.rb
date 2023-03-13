require "rails_helper"

RSpec.describe ConsentForm do
  let(:intake) { create :intake, primary_birth_date: dob }
  let(:dob) { nil }
  let(:valid_params_with_dob) do
    {
      birth_date_year: "1983",
      birth_date_month: "5",
      birth_date_day: "10",
      primary_first_name: "Greta",
      primary_last_name: "Gnome",
    }
  end

  let(:valid_params_without_dob) do
    {
      primary_first_name: "Greta",
      primary_last_name: "Gnome",
    }
  end

  describe "validations" do
    context "triaged client" do
      before do
        allow(intake).to receive(:triaged_intake?).and_return(true)
      end

      context "when all params are valid" do
        it "is valid" do
          form = ConsentForm.new(intake, valid_params_with_dob)

          expect(form).to be_valid
        end
      end

      context "required params are missing" do
        it "adds errors for each; requires birth date" do
          form = ConsentForm.new(
            intake,
            {
              birth_date_year: "1983",
              birth_date_month: nil,
              birth_date_day: "10",
              primary_first_name: "Greta",
              primary_last_name: nil,
            }
          )

          expect(form).not_to be_valid
          expect(form.errors[:birth_date]).to be_present
          expect(form.errors[:primary_last_name]).to be_present
        end
      end

      context "when the date is not valid" do
        let(:params) { valid_params_with_dob.merge(birth_date_month: "2", birth_date_day: "31") }

        it "adds a validation error" do
          form = ConsentForm.new(intake, params)

          expect(form).not_to be_valid
          expect(form.errors[:birth_date]).to be_present
          expect(form.errors[:birth_date]).to include "Please select a valid date"
        end
      end
    end

    context "not triaged client" do
      let(:dob) { Date.parse("1989-08-22") }

      before do
        allow(intake).to receive(:triaged_intake?).and_return(false)
      end

      context "when all params are valid and don't include DOB params" do
        it "is valid" do
          form = ConsentForm.new(intake, valid_params_without_dob)

          expect(form).to be_valid
        end
      end

      context "required params are missing" do
        it "adds errors for each; does not require birth date" do
          form = ConsentForm.new(
            intake,
            {
              birth_date_year: nil,
              birth_date_month: nil,
              birth_date_day: nil,
              primary_first_name: "Greta",
              primary_last_name: nil,
            }
          )

          expect(form).not_to be_valid
          expect(form.errors[:birth_date]).not_to be_present
          expect(form.errors[:primary_last_name]).to be_present
        end
      end

      # this is an edge case that could happen if the client fills out triage-personal-info, bails, then starts
      # intake with a link that skips triage. this would cause them to skip the personal info page, which asks for
      # birth date, so at this point we would still need their birth date.
      context "when the triage income levels questions are unfilled but the client still doesn't have a birth date" do
        let(:dob) { nil }

        it "requires birth date params" do
          form = ConsentForm.new(
            intake,
            {
              birth_date_year: nil,
              birth_date_month: nil,
              birth_date_day: nil,
              primary_first_name: "Greta",
              primary_last_name: "Gourd",
            }
          )

          expect(form).not_to be_valid
          expect(form.errors[:birth_date]).to be_present
        end
      end
    end
  end

  describe "#save" do
    before do
      allow(DateTime).to receive(:now).and_return DateTime.new(2025, 2, 7, 11, 10, 1)
    end

    context "triaged client" do
      before do
        allow(intake).to receive(:triaged_intake?).and_return(true)
      end

      it "parses & saves the correct data to the model record" do
        form = ConsentForm.new(intake, valid_params_with_dob)
        form.save
        intake.reload

        expect(intake.primary.birth_date).to eq Date.new(1983, 5, 10)
      end
    end

    context "not triaged client" do
      let(:dob) { Date.parse("1989-08-22") }

      before do
        allow(intake).to receive(:triaged_intake?).and_return(false)
      end

      it "saves the correct data to the model record; does not update birth date" do
        form = ConsentForm.new(intake, valid_params_without_dob)
        expect {
          form.save
        }.not_to change(intake, :primary_birth_date)
      end
    end
  end

  describe "#existing_attributes" do
    let(:populated_intake) { build :intake, primary_birth_date: Date.new(1983, 5, 10) }

    it "returns a hash with the date fields populated" do
      attributes = ConsentForm.existing_attributes(populated_intake)

      expect(attributes[:birth_date_year]).to eq 1983
      expect(attributes[:birth_date_month]).to eq 5
      expect(attributes[:birth_date_day]).to eq 10
    end
  end
end