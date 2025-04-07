require 'rails_helper'

describe StateFile::NjTenantEligibilityHelper do
  describe "#determine_eligibility" do
    describe "ineligible states" do
      context "when NO to tenant_home_subject_to_property_taxes" do
        let(:intake) { create :state_file_nj_intake, tenant_home_subject_to_property_taxes: "no" }
        it "returns ineligible" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::INELIGIBLE)
        end
      end

      context "when NO to tenant_access_kitchen_bath" do
        let(:intake) {
          create :state_file_nj_intake,
                 tenant_building_multi_unit: "yes",
                 tenant_access_kitchen_bath: "no"
        }
        it "returns ineligible" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::INELIGIBLE)
        end
      end
    end

    describe "advance states" do
      context "when YES to tenant_home_subject_to_property_taxes" do
        let(:intake) { create :state_file_nj_intake, tenant_home_subject_to_property_taxes: "yes" }
        it "returns advance" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::ADVANCE)
        end
      end

      context "when NO to tenant_more_than_one_main_home_in_nj" do
        let(:intake) { create :state_file_nj_intake, tenant_more_than_one_main_home_in_nj: "no" }
        it "returns advance" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::ADVANCE)
        end
      end

      context "when NO to tenant_shared_rent_not_spouse" do
        let(:intake) { create :state_file_nj_intake, tenant_shared_rent_not_spouse: "no" }
        it "returns advance" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::ADVANCE)
        end
      end

      context "when NO to tenant_building_multi_unit" do
        let(:intake) { create :state_file_nj_intake, tenant_building_multi_unit: "no" }
        it "returns advance" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::ADVANCE)
        end
      end

      context "when NO to tenant_same_home_spouse" do
        let(:intake) { create :state_file_nj_intake, tenant_same_home_spouse: "no" }
        it "returns advance" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::ADVANCE)
        end
      end

      context "when YES to tenant_same_home_spouse" do
        let(:intake) { create :state_file_nj_intake, tenant_same_home_spouse: "yes" }
        it "returns advance" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::ADVANCE)
        end
      end
    end

    describe "multiple checkbox interactions" do
      context "taxpayer selects checkboxes that correspond to both ineligible and worksheet required states" do
        let(:intake) {
          create :state_file_nj_intake,
                 tenant_home_subject_to_property_taxes: "no", # ineligible
                 tenant_more_than_one_main_home_in_nj: "yes" # worksheet required
        }
        it "determines the taxpayer is ineligible" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::INELIGIBLE)
        end
      end

      context "taxpayer selects checkboxes that correspond to both ineligible and advance states" do
        let(:intake) {
          create :state_file_nj_intake,
                 tenant_home_subject_to_property_taxes: "no", # ineligible
                 tenant_more_than_one_main_home_in_nj: "no" # advance
        }
        it "determines the taxpayer is ineligible" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::INELIGIBLE)
        end
      end

      context "taxpayer selects checkboxes that correspond to both worksheet required and advance states" do
        let(:intake) {
          create :state_file_nj_intake,
                 tenant_shared_rent_not_spouse: "yes", # worksheet required
                 tenant_more_than_one_main_home_in_nj: "no" # advance
        }
        it "determines the taxpayer should advance" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::ADVANCE)
        end
      end
    end
  end
end






