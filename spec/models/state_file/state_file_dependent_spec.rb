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

  describe "asking additional AZ senior questions" do
    it "asks more questions when a dependent is 65+ by the end of the tax year + grandparent + 12 months in home" do
      dependent = build(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        relationship: "GRANDPARENT"
      )

      expect(dependent.ask_senior_questions?).to be true
    end

    it "asks more questions when a dependent is 65+ by the end of the tax year + parent + 12 months in home" do
      dependent = build(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        relationship: "PARENT"
      )

      expect(dependent.ask_senior_questions?).to be true
    end

    it "does NOT ask more questions when a dependent is 65+ AFTER the end of the tax year + grandparent + 12 months in home" do
      dependent = build(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date + 1.day,
        months_in_home: 12,
        relationship: "GRANDPARENT"
      )

      expect(dependent.ask_senior_questions?).to be false
    end

    it "does NOT ask more questions when a dependent is 65+ by the end of the tax year + NOT parent or grandparent + 12 months in home" do
      dependent = build(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        relationship: "DAUGHTER"
      )

      expect(dependent.ask_senior_questions?).to be false
    end

    it "does NOT ask more questions when a dependent is 65+ by the end of the tax year + grandparent + LESS THAN 12 months in home" do
      dependent = build(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 11,
        relationship: "GRANDPARENT"
      )

      expect(dependent.ask_senior_questions?).to be false
    end
  end

  describe "detecting qualified parents or grandparents for dependents that are 65+" do
    it "only returns dependents that are 65+ by end of tax year, a grandparent or parent, spent 12 months in home, and needed assistance" do
      qualifying_grandparent = create(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        needed_assistance: "yes",
        relationship: "GRANDPARENT"
      )
      qualifying_parent = create(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        needed_assistance: "yes",
        relationship: "PARENT"
      )
      too_young = create(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date + 1.day,
        months_in_home: 12,
        needed_assistance: "yes",
        relationship: "GRANDPARENT"
      )
      not_ancestor = create(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        needed_assistance: "yes",
        relationship: "DAUGHTER"
      )
      too_few_months = create(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 11,
        needed_assistance: "yes",
        relationship: "GRANDPARENT"
      )
      did_not_need_assistance = create(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        needed_assistance: "no",
        relationship: "GRANDPARENT"
      )
      expect(qualifying_grandparent.is_qualifying_parent_or_grandparent?).to be true
      expect(qualifying_parent.is_qualifying_parent_or_grandparent?).to be true
      expect(too_young.is_qualifying_parent_or_grandparent?).to be false
      expect(not_ancestor.is_qualifying_parent_or_grandparent?).to be false
      expect(too_few_months.is_qualifying_parent_or_grandparent?).to be false
      expect(did_not_need_assistance.is_qualifying_parent_or_grandparent?).to be false
    end
  end

  describe "#age" do
    it "when the birthday is the last day of the tax year" do
      dependent = build(
        :state_file_dependent,
        dob: (MultiTenantService.statefile.end_of_current_tax_year - 10.years).strftime("%Y-%m-%d")
      )
      expect(dependent.age).to be 10
    end
    it "when the birthday is the first day of the next tax year" do
      dependent = build(
        :state_file_dependent,
        dob: (MultiTenantService.statefile.end_of_current_tax_year + 1.days - 10.years).strftime("%Y-%m-%d")
      )
      expect(dependent.age).to be 9
    end
  end

  describe "#relationship_label" do
    it "provides a correct gender neutral relationship label" do
      dependent = build(:state_file_dependent, relationship: "STEPBROTHER")
      expect(dependent.relationship_label).to eq "Step-Sibling"
    end
  end
end