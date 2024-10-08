require 'rails_helper'

describe StateFile::NjTenantEligibilityHelper do
  describe "#determine_eligibility" do
    describe "hard no ineligible states" do
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

    describe "soft no unsupported states" do
      context "when YES to tenant_more_than_one_main_home_in_nj" do
        let(:intake) { create :state_file_nj_intake, tenant_more_than_one_main_home_in_nj: "yes" }
        it "returns unsupported" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::UNSUPPORTED)
        end
      end

      context "when YES to tenant_shared_rent_not_spouse" do
        let(:intake) {  create :state_file_nj_intake, tenant_shared_rent_not_spouse: "yes" }
        it "returns unsupported" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::UNSUPPORTED)
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
      context "when a hard no overrides a soft no" do
        let(:intake) {
          create :state_file_nj_intake,
                 tenant_home_subject_to_property_taxes: "no", # hard no
                 tenant_more_than_one_main_home_in_nj: "yes" # soft no
        }
        it "returns ineligible" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::INELIGIBLE)
        end
      end

      context "when a hard no overrides an advance" do
        let(:intake) {
          create :state_file_nj_intake,
                 tenant_home_subject_to_property_taxes: "no", # hard no
                 tenant_more_than_one_main_home_in_nj: "no" # advance
        }
        it "returns ineligible" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::INELIGIBLE)
        end
      end

      context "when a soft no overrides an advance" do
        let(:intake) {
          create :state_file_nj_intake,
                 tenant_shared_rent_not_spouse: "yes", # soft no
                 tenant_more_than_one_main_home_in_nj: "no" # advance
        }
        it "returns unsupported" do
          expect(described_class.determine_eligibility(intake)).to eq(described_class::UNSUPPORTED)
        end
      end
    end
  end
end






