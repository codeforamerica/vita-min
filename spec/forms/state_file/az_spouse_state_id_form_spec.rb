require "rails_helper"

RSpec.describe StateFile::AzSpouseStateIdForm do
  let!(:intake) { create :state_file_ny_intake, spouse_state_id: nil }
  let(:valid_params) do
    {
        "id_type" => "driver_license",
        "id_number" => "123456789",
        "issue_date_month" => "3",
        "issue_date_day" => "6",
        "issue_date_year" => "2016",
        "expiration_date_month" => "4",
        "expiration_date_day" => "5",
        "expiration_date_year" => "2026",
        "state" => "AZ"
    }
  end

  describe "#save" do
    context "when params valid" do
      it "saves values" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.spouse_state_id).to be_present
        expect(intake.spouse_state_id.id_type).to eq "driver_license"
        expect(intake.spouse_state_id.id_number).to eq "123456789"
        expect(intake.spouse_state_id.issue_date).to eq Date.parse("March 6, 2016")
        expect(intake.spouse_state_id.expiration_date).to eq Date.parse("April 5, 2026")
        expect(intake.spouse_state_id.state).to eq "AZ"
      end
    end
  end

  describe "#valid?" do
    context "when no state id" do
      let(:params) do
        {
          id_type: "no_id",
          id_number: "",
          issue_date_month: "",
          issue_date_day: "",
          issue_date_year: "",
          expiration_date_month: "",
          expiration_date_day: "",
          expiration_date_year: "",
          state: ""
        }
      end

      it "doesn't require other fields" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
        expect(form.errors).to be_empty
      end
    end

    context "when id type driver license" do
      let(:params) do
        {
          id_type: "driver_license",
          id_number: "",
          issue_date_month: "",
          issue_date_day: "",
          issue_date_year: "",
          expiration_date_month: "",
          expiration_date_day: "",
          expiration_date_year: "",
          state: ""
        }
      end

      it "requires other fields" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors).to include :id_number
        expect(form.errors).to include :issue_date
        expect(form.errors).to include :expiration_date
        expect(form.errors).to include :state
      end
    end
  end
end