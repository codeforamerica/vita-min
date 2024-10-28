require 'rails_helper'

describe Efile::Nj::NjSenior do
  describe ".is_over_65" do
    context "when birth_date not present" do
      let(:intake) { create(:state_file_nj_intake) }
      it "returns false" do
        result = Efile::Nj::NjSenior.is_over_65(intake.spouse_birth_date)
        expect(result).to eq(false)
      end
    end

    context "when birth_date over 65 years ago" do
      let(:intake) { create(:state_file_nj_intake, :primary_over_65) }
      it "returns true" do
        result = Efile::Nj::NjSenior.is_over_65(intake.primary_birth_date)
        expect(result).to eq(true)
      end
    end

    context "when birth_date under 65 years ago" do
      let(:intake) { create(:state_file_nj_intake) }
      it "returns false" do
        result = Efile::Nj::NjSenior.is_over_65(intake.primary_birth_date)
        expect(result).to eq(false)
      end
    end
  end
end
