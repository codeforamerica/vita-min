require "rails_helper"

RSpec.describe StateFile::NjGubernatorialElectionsForm do
  let(:intake) { create :state_file_nj_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }

    context "single invalid params" do
      context "all fields are required" do
        let(:invalid_params) do
          {
            :primary_contribution_gubernatorial_elections => nil,
            :spouse_contribution_gubernatorial_elections => nil, 
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:primary_contribution_gubernatorial_elections]).to include "Can't be blank."
          expect(form.errors[:spouse_contribution_gubernatorial_elections].length).to be 0 
        end
      end
    end

    context "mfj invalid params" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly }

      context "all fields are required" do
        let(:invalid_params) do
          {
            :primary_contribution_gubernatorial_elections => nil,
            :spouse_contribution_gubernatorial_elections => nil, 
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:primary_contribution_gubernatorial_elections]).to include "Can't be blank."
          expect(form.errors[:spouse_contribution_gubernatorial_elections]).to include "Can't be blank."
        end
      end
    end
  end

  describe ".save" do
    let(:intake) {
      create :state_file_nj_intake,
      :married_filing_jointly,
      primary_contribution_gubernatorial_elections: 'no',
      spouse_contribution_gubernatorial_elections: 'no'
    }
    let(:form) { described_class.new(intake, valid_params) }

    context "when saving a new selection" do
      let(:valid_params) do
        { primary_contribution_gubernatorial_elections: "yes", spouse_contribution_gubernatorial_elections: "yes" }
      end

      it "saves attributes" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.primary_contribution_gubernatorial_elections).to eq "yes"
        expect(intake.spouse_contribution_gubernatorial_elections).to eq "yes"
      end
    end
  end
end
