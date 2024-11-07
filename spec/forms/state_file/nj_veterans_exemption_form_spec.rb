require "rails_helper"

RSpec.describe StateFile::NjVeteransExemptionForm do
  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }
    let(:invalid_params) do
      { 
        :primary_veteran => nil,
        :spouse_veteran => nil
      }
    end
    context "when filing status is single and fields are empty" do
      let(:intake) {
        create :state_file_nj_intake
      }
      it "flags the primary_veteran field as an error but not the spouse_veteran field" do
        expect(form.valid?).to eq false
        expect(form.errors[:primary_veteran]).to include "Can't be blank."
        expect(form.errors[:spouse_veteran]).to eq []
      end
    end

    context "when filing status is married filing jointly and fields are empty" do
      let(:intake) {
        create :state_file_nj_intake, :married_filing_jointly
      }
      it "flags the both primary_veteran and spouse_veteran fields as an error" do
        expect(form.valid?).to eq false
        expect(form.errors[:primary_veteran]).to include "Can't be blank."
        expect(form.errors[:spouse_veteran]).to include "Can't be blank."
      end
    end
  end

  describe ".save" do
    let(:intake) {
      create :state_file_nj_intake, primary_veteran: nil, spouse_veteran: nil
    }
    let(:form) { described_class.new(intake, valid_params) }

    context "when saving primary and spouse veteran statuses" do
      let(:valid_params) do
        { 
          :primary_veteran => "yes",
          :spouse_veteran => "yes"
        }
      end

      it "saves attributes" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.primary_veteran).to eq "yes"
        expect(intake.spouse_veteran).to eq "yes"
      end
    end
  end
end