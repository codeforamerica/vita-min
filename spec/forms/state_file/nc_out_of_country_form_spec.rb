require "rails_helper"

RSpec.describe StateFile::NcOutOfCountryForm do
  describe "#valid?" do
    let(:intake) { create :state_file_nc_intake }
    let(:out_of_country) { nil }
    let(:params) do
      {
        out_of_country: out_of_country
      }
    end
    let(:form) {  described_class.new(intake, params) }

    context "with no radio selected" do
      it "returns false" do
        expect(form).not_to be_valid
        expect(form.errors).to include(:out_of_country)
      end
    end

    context "with no selected" do
      let(:out_of_country) { "no" }

      it "returns true" do
        expect(form).to be_valid
      end
    end

    context "with yes selected" do
      let(:out_of_country) { "yes" }

      it "returns true" do
        expect(form).to be_valid
      end
    end
  end
end
