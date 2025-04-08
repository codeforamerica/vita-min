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
                 tenant_home_subject_to_property_taxes: "yes",
                 tenant_building_multi_unit: "yes",
                 tenant_access_kitchen_bath: "no"
        }
        it "returns ineligible" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::INELIGIBLE)
        end
      end

      context "when none of the above" do
        let(:intake) {
          create :state_file_nj_intake,
                 tenant_home_subject_to_property_taxes: "no",
                 tenant_building_multi_unit: "no",
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

      context "when YES to all checkboxes" do
        let(:intake) { create :state_file_nj_intake, tenant_home_subject_to_property_taxes: "yes", tenant_building_multi_unit: "yes", tenant_access_kitchen_bath: "yes" }
        it "returns advance" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::ADVANCE)
        end
      end
    end
  end
end






