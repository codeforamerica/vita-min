require 'rails_helper'

RSpec.describe StateFile::MdCountyForm, type: :model do
  describe "validations" do
    it { should validate_presence_of(:residence_county) }
    it { should validate_inclusion_of(:residence_county).in_array(MdResidenceCountyConcern::COUNTIES_AND_SUBDIVISIONS.keys) }
    it { should validate_presence_of(:subdivision_code) }
    it { should validate_inclusion_of(:subdivision_code).in_array(subject.valid_subdivisions) }
  end


  describe "#save" do
    let(:intake) {create(:state_file_md_intake)}
    let(:form) { described_class.new(intake, valid_params) }
    let(:valid_params) do
      {
        residence_county: "Allegany",
        subdivision_code: "0101"
      }
    end

    it "saves attributes" do
      expect(form.valid?).to eq true
      form.save

      expect(intake.residence_county).to eq "Allegany"
      expect(intake.subdivision_code).to eq "0101"
      expect(intake.political_subdivision).to eq "Town Of Barton"
    end
  end

  describe "#valid_subdivisions" do
    let(:form) { StateFile::MdCountyForm.new }

    context "when county is present" do
      before { form.residence_county = "Anne Arundel" }

      it "returns subdivisions for the selected county" do
        expect(form.valid_subdivisions).to eq(["0200", "0201", "0203"])
      end
    end

    context "when county is blank" do
      it "returns all subdivisions" do
        all_subdivisions = MdResidenceCountyConcern::COUNTIES_AND_SUBDIVISIONS.values.flat_map(&:values)
        expect(form.valid_subdivisions).to eq(all_subdivisions)
      end
    end
  end

  describe "#subdivision_name" do
    let(:form) { StateFile::MdCountyForm.new }

    context "when residence_county and subdivision_code are present" do
      before do
        form.residence_county = "Anne Arundel"
        form.subdivision_code = "0201"
      end

      it "returns the correct subdivision name" do
        expect(form.subdivision_name).to eq("City Of Annapolis")
      end
    end

    context "when residence_county or subdivision_code is blank" do
      it "returns nil" do
        expect(form.subdivision_name).to be_nil
      end
    end
  end

  describe "#all_subdivisions" do
    let(:form) { StateFile::MdCountyForm.new }

    it "returns all subdivision codes" do
      all_subdivisions = MdResidenceCountyConcern::COUNTIES_AND_SUBDIVISIONS.values.flat_map(&:values)
      expect(form.all_subdivisions).to eq(all_subdivisions)
    end
  end
end