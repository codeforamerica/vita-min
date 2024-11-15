require "rails_helper"

describe StateFileDependent do
  describe "validations" do
    context "in the az_senior_form context" do
      context "when needed assistance is yes" do
        it "is valid" do
          dependent = build(:state_file_dependent, needed_assistance: "yes", passed_away: "yes")
          expect(dependent.valid?(:az_senior_form)).to eq true
        end
      end

      context "when needed assistance is no" do
        it "is valid" do
          dependent = build(:state_file_dependent, needed_assistance: "no", passed_away: "yes")
          expect(dependent.valid?(:az_senior_form)).to eq true
        end
      end

      context "when needed assistance is unfilled" do
        it "is not valid" do
          dependent = build(:state_file_dependent, needed_assistance: "unfilled", passed_away: "yes")
          expect(dependent.valid?(:az_senior_form)).to eq false
          expect(dependent.errors).to include :needed_assistance
        end
      end

      context "when passed_away is yes" do
        it "is valid" do
          dependent = build(:state_file_dependent, passed_away: "yes", needed_assistance: "yes")
          expect(dependent.valid?(:az_senior_form)).to eq true
        end
      end

      context "when passed_away is no" do
        it "is valid" do
          dependent = build(:state_file_dependent, passed_away: "no", needed_assistance: "yes")
          expect(dependent.valid?(:az_senior_form)).to eq true
        end
      end

      context "when passed_away is unfilled" do
        it "is not valid" do
          dependent = build(:state_file_dependent, passed_away: "unfilled", needed_assistance: "yes")
          expect(dependent.valid?(:az_senior_form)).to eq false
          expect(dependent.errors).to include :passed_away
        end
      end
    end
  end

  describe "#ask_senior_questions?" do
    let(:dependent) { build(:state_file_dependent, dob: dob, months_in_home: months_in_home, relationship: relationship, intake: intake) }
    let(:relationship) { "grandParent" }
    let(:dob) { described_class.senior_cutoff_date }
    let(:months_in_home) { 12 }
    let(:intake) { build :state_file_az_intake }

    context "when spent 12 months in home" do
      context "when a dependent is 65+" do
        context "when grandparent" do
          it "asks more questions" do
            expect(dependent.ask_senior_questions?).to be true
          end
        end

        context "when parent" do
          let(:relationship) { "parent" }
          it "asks more questions" do
            expect(dependent.ask_senior_questions?).to be true
          end
        end

        context "when daughter (not parent or grandparent)" do
          let(:relationship) { "biologicalChild" }
          it "doesn't asks more questions" do
            expect(dependent.ask_senior_questions?).to be false
          end
        end
      end

      context "when a dependent is younger than 65" do
        let(:dob) { described_class.senior_cutoff_date + 1.week }
        it "does NOT ask more questions" do
          expect(dependent.ask_senior_questions?).to be false
        end
      end

      context "when dependent's birthday is one day from the cutoff (January 1st)" do
        let(:dob) { described_class.senior_cutoff_date + 1.day }
        context "when Maryland intake" do
          let(:intake) { build :state_file_md_intake }
          it "doesn't ask more questions" do
            expect(dependent.ask_senior_questions?).to be false
          end
        end

        context "when following federal age guidelines" do
          it "doesn't ask more questions" do
            expect(dependent.ask_senior_questions?).to be true
          end
        end
      end
    end

    context "when less than 12 months in the home" do
      let(:months_in_home) { 11 }
      it "does NOT ask more questions" do
        expect(dependent.ask_senior_questions?).to be false
      end
    end
  end

  describe "#is_qualifying_parent_or_grandparent?" do
    it "only returns dependents that are 65+ by end of tax year, a grandparent or parent, spent 12 months in home, and needed assistance" do
      qualifying_grandparent = build(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        needed_assistance: "yes",
        relationship: "grandParent"
      )
      qualifying_parent = build(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        needed_assistance: "yes",
        relationship: "parent"
      )
      too_young = build(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date + 2.day,
        months_in_home: 12,
        needed_assistance: "yes",
        relationship: "grandParent"
      )
      jan_1_az_intake = build(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date + 1.day,
        months_in_home: 12,
        needed_assistance: "yes",
        relationship: "grandParent"
      )
      jan_1_md_intake = build(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date + 1.day,
        months_in_home: 12,
        needed_assistance: "yes",
        relationship: "grandParent",
        intake: build(:state_file_md_intake)
      )
      not_ancestor = build(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        needed_assistance: "yes",
        relationship: "biologicalChild"
      )
      too_few_months = build(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 11,
        needed_assistance: "yes",
        relationship: "grandParent"
      )
      did_not_need_assistance = build(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        needed_assistance: "no",
        relationship: "grandParent"
      )
      expect(qualifying_grandparent.is_qualifying_parent_or_grandparent?).to be true
      expect(qualifying_parent.is_qualifying_parent_or_grandparent?).to be true
      expect(too_young.is_qualifying_parent_or_grandparent?).to be false
      expect(jan_1_az_intake.is_qualifying_parent_or_grandparent?).to be true
      expect(jan_1_md_intake.is_qualifying_parent_or_grandparent?).to be false
      expect(not_ancestor.is_qualifying_parent_or_grandparent?).to be false
      expect(too_few_months.is_qualifying_parent_or_grandparent?).to be false
      expect(did_not_need_assistance.is_qualifying_parent_or_grandparent?).to be false
    end
  end

  describe "#under_17?" do
    let(:dob_jan_1_16_years_ago) { Date.new((MultiTenantService.statefile.current_tax_year - 16), 1, 1) }
    let(:dependent_17_next_year) { create :state_file_dependent, dob: dob_jan_1_16_years_ago, intake: intake }

    let(:dob_jan_1_17_years_ago) { Date.new((MultiTenantService.statefile.current_tax_year - 17), 1, 1) }
    let(:dependent_17_this_year) { create :state_file_dependent, dob: dob_jan_1_17_years_ago, intake: intake }

    let(:intake) { create :state_file_az_intake }

    context "when following federal guidelines for benefits dependents age out of" do
      it "Jan 1st b-days are considered older on Jan 1st" do
        expect(dependent_17_next_year.under_17?).to eq true
        expect(dependent_17_this_year.under_17?).to eq false
      end
    end

    context "when following Maryland guidelines" do
      let(:intake) { create :state_file_md_intake }
      it "Jan 1st b-days are considered older on Jan 1st" do
        expect(dependent_17_next_year.under_17?).to eq true
        expect(dependent_17_this_year.under_17?).to eq false
      end
    end
  end

  describe "#senior?" do
    let(:dob_jan_1_64_years_ago) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 64), 1, 1) }
    let(:dependent_65_next_year) { create :state_file_dependent, dob: dob_jan_1_64_years_ago, intake: intake }

    let(:dob_jan_1_65_years_ago) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 65), 1, 1) }
    let(:dependent_65_this_year) { create :state_file_dependent, dob: dob_jan_1_65_years_ago, intake: intake }

    let(:intake) { create :state_file_az_intake }

    context "when following federal guidelines for benefits dependents age into" do
      it "Jan 1st b-days are considered older on Dec 31st" do
        expect(dependent_65_next_year.senior?).to eq true
        expect(dependent_65_this_year.senior?).to eq true
      end
    end

    context "when following Maryland guidelines" do
      let(:intake) { create :state_file_md_intake }
      it "Jan 1st b-days are considered older on Jan 1st" do
        expect(dependent_65_next_year.senior?).to eq false
        expect(dependent_65_this_year.senior?).to eq true
      end
    end
  end

  describe "#relationship_label" do
    it "provides a correct gender neutral relationship label" do
      dependent = build(:state_file_dependent, relationship: "stepSibling")
      expect(dependent.relationship_label).to eq "Step-Sibling"
    end
  end

  describe "#months_in_home_for_pdf" do
    let(:intake) { create :state_file_az_johnny_intake }

    it "outputs the correct labels when all dependents have between 6-12 months in home" do
      expect(intake.dependents.where(first_name: "Ronnie").first.months_in_home_for_pdf).to eq("12")
      expect(intake.dependents.where(first_name: "Twyla").first.months_in_home_for_pdf).to eq("7")
      expect(intake.dependents.where(first_name: "David").first.months_in_home_for_pdf).to eq("12")
      expect(intake.dependents.where(first_name: "Roland").first.months_in_home_for_pdf).to eq("12")
      expect(intake.dependents.where(first_name: "Stevie").first.months_in_home_for_pdf).to eq("8")
      expect(intake.dependents.where(first_name: "Wendy").first.months_in_home_for_pdf).to eq("12")
      expect(intake.dependents.where(first_name: "Alexis").first.months_in_home_for_pdf).to eq("12")
    end

    it "outputs the correct labels when a dependent has nil months in home" do
      ronnie = intake.dependents.where(first_name: "Ronnie").first
      ronnie.months_in_home = nil

      expect(ronnie.months_in_home_for_pdf).to eq("<6")
    end
  end

  describe "#months_in_home_for_xml" do
    let(:intake) { create :state_file_az_johnny_intake }

    it "outputs the correct labels when all dependents have between 6-12 months in home" do
      expect(intake.dependents.where(first_name: "Ronnie").first.months_in_home_for_xml).to eq(12)
      expect(intake.dependents.where(first_name: "Twyla").first.months_in_home_for_xml).to eq(7)
      expect(intake.dependents.where(first_name: "David").first.months_in_home_for_xml).to eq(12)
      expect(intake.dependents.where(first_name: "Roland").first.months_in_home_for_xml).to eq(12)
      expect(intake.dependents.where(first_name: "Stevie").first.months_in_home_for_xml).to eq(8)
      expect(intake.dependents.where(first_name: "Wendy").first.months_in_home_for_xml).to eq(12)
      expect(intake.dependents.where(first_name: "Alexis").first.months_in_home_for_xml).to eq(12)
    end

    it "outputs the correct labels when a dependent has nil months in home" do
      ronnie = intake.dependents.where(first_name: "Ronnie").first
      ronnie.months_in_home = nil

      expect(ronnie.months_in_home_for_xml).to eq(5)
    end
  end

  describe "#eligible_for_child_tax_credit" do
    let(:intake) { create :state_file_az_intake }
    let(:dob_jan_1_16_years_ago) { Date.new((MultiTenantService.statefile.current_tax_year - 16), 1, 1) }
    let(:dependent_17_next_year) { create :state_file_dependent, dob: dob_jan_1_16_years_ago, intake: intake, relationship: "biologicalChild" }
    let(:dependent_17_this_year) { create :state_file_dependent, dob: dob_jan_1_16_years_ago - 1.year, intake: intake, relationship: "biologicalChild" }
    let(:dependent_17_next_year_with_ineligible_relationship) { create :state_file_dependent, dob: dob_jan_1_16_years_ago - 1.year, intake: intake, relationship: "noneOfTheAbove" }

    it "returns true only for eligible dependents" do
      expect(dependent_17_next_year.eligible_for_child_tax_credit).to be(true)
      expect(dependent_17_this_year.eligible_for_child_tax_credit).to be(false)
      expect(dependent_17_next_year_with_ineligible_relationship.eligible_for_child_tax_credit).to be(false)
    end

  end
end