require "rails_helper"

RSpec.describe StateFile::NjDisabledExemptionForm do
  describe "validations" do
    context "when filing status is married filing jointly and fields are empty" do
      let(:form) { described_class.new(intake, empty_params) }
      let(:empty_params) do
        { 
          :primary_disabled => nil,
          :spouse_disabled => nil
        }
      end

      context "primary has not claimed the blind exemption, spouse has claimed the blind exemption" do
        let(:intake) { create :state_file_nj_intake, :married_filing_jointly, :spouse_blind }
        it "flags the primary_disabled field as an error but not the spouse_disabled field" do
          expect(form.valid?).to eq false
          expect(form.errors[:primary_disabled]).to include "Can't be blank."
          expect(form.errors[:spouse_disabled]).to eq []
        end
      end

      context "primary has claimed the blind exemption, spouse has claimed the blind exemption" do
        let(:intake) { create :state_file_nj_intake, :married_filing_jointly, :primary_blind, :spouse_blind }
        it "is valid" do
          expect(form.valid?).to eq true
          expect(form.errors[:primary_disabled]).to eq []
          expect(form.errors[:spouse_disabled]).to eq []
        end
      end

      context "neither the primary nor the spouse claim the blind exemption" do
        let(:intake) { create :state_file_nj_intake, :married_filing_jointly }
        it "specifies that both primary_disabled and spouse_disabled must be filled" do
          expect(form.valid?).to eq false
          expect(form.errors[:primary_disabled]).to include "Can't be blank."
          expect(form.errors[:spouse_disabled]).to include "Can't be blank."
        end
      end
    end

    context "when filing status is single" do
      let(:form) { described_class.new(intake, empty_params) }
      let(:empty_params) do
        { 
          :primary_disabled => nil,
          :spouse_disabled => nil
        }
      end

      context "primary has claimed the blind exemption" do
        let(:intake) { create :state_file_nj_intake, :primary_blind }
        it "is valid" do
          expect(form.valid?).to eq true
          expect(form.errors[:primary_disabled]).to eq []
          expect(form.errors[:spouse_disabled]).to eq []
        end
      end

      context "primary has not claimed the blind exemption" do
        let(:intake) { create :state_file_nj_intake }
        it "specifies that both primary_disabled must be filled" do
          expect(form.valid?).to eq false
          expect(form.errors[:primary_disabled]).to include "Can't be blank."
          expect(form.errors[:spouse_disabled]).to eq []
        end
      end
    end
  end

  describe ".save" do
    let(:intake) {
      create :state_file_nj_intake, primary_disabled: nil, spouse_disabled: nil
    }
    let(:form) { described_class.new(intake, valid_params) }

    context "when saving primary and spouse disabled statuses" do
      let(:valid_params) do
        { 
          primary_disabled: "yes",
          spouse_disabled: "yes"
        }
      end

      it "saves attributes" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.primary_disabled).to eq "yes"
        expect(intake.spouse_disabled).to eq "yes"
      end
    end
  end
end
