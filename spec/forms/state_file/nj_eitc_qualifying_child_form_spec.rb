require "rails_helper"

RSpec.describe StateFile::NjEitcQualifyingChildForm do
  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }
    let(:invalid_params) do
      { 
        :claimed_as_eitc_qualifying_child => nil,
        :spouse_claimed_as_eitc_qualifying_child => nil
      }
    end
    context "when filing status is single and fields are empty" do
      let(:intake) {
        create :state_file_nj_intake
      }
      it "flags claimed_as_eitc_qualifying_child as an error but not spouse_claimed_as_eitc_qualifying_child" do
        expect(form.valid?).to eq false
        expect(form.errors[:claimed_as_eitc_qualifying_child]).to include "Can't be blank."
        expect(form.errors[:spouse_claimed_as_eitc_qualifying_child]).to eq []
      end
    end

    context "when filing status is married filing jointly and fields are empty" do
      let(:intake) {
        create :state_file_nj_intake, :married_filing_jointly
      }
      it "flags both claimed_as_eitc_qualifying_child and spouse_claimed_as_eitc_qualifying_child as an error" do
        expect(form.valid?).to eq false
        expect(form.errors[:claimed_as_eitc_qualifying_child]).to include "Can't be blank."
        expect(form.errors[:spouse_claimed_as_eitc_qualifying_child]).to include "Can't be blank."
      end
    end
  end

  describe ".save" do
    let(:intake) {
      create :state_file_nj_intake, claimed_as_eitc_qualifying_child: nil, spouse_claimed_as_eitc_qualifying_child: nil
    }
    let(:form) { described_class.new(intake, valid_params) }

    context "when saving primary and spouse statuses" do
      let(:valid_params) do
        { 
          :claimed_as_eitc_qualifying_child => "yes",
          :spouse_claimed_as_eitc_qualifying_child => "yes"
        }
      end

      it "saves attributes" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.claimed_as_eitc_qualifying_child).to eq "yes"
        expect(intake.spouse_claimed_as_eitc_qualifying_child).to eq "yes"
      end
    end
  end
end
