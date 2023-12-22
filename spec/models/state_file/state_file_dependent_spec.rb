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

  describe ".az_qualifying_senior" do
    it "only returns dependents that are 65+ by end of tax year, a grandparent or parent, and 12 months in home" do
      qualifying_grandparent = create(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        relationship: "GRANDPARENT"
      )
      qualifying_parent = create(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        relationship: "PARENT"
      )
      too_young = create(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date + 1.day,
        months_in_home: 12,
        relationship: "GRANDPARENT"
      )
      not_ancestor = create(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 12,
        relationship: "DAUGHTER"
      )
      too_few_months = create(
        :state_file_dependent,
        dob: described_class.senior_cutoff_date,
        months_in_home: 11,
        relationship: "GRANDPARENT"
      )
      results = described_class.az_qualifying_senior
      expect(results).to include qualifying_grandparent
      expect(results).to include qualifying_parent
      expect(results).not_to include too_young
      expect(results).not_to include not_ancestor
      expect(results).not_to include too_few_months
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

  describe "age calculates correctly" do
    it "when the birthday is yesterday" do
      dependent = build(
        :state_file_dependent,
        dob: ((Time.now.beginning_of_day - 1.days) - 10.years).strftime("%Y-%m-%d")
        )
      expect(dependent.age).to be 10
    end
    it "when the birthday is today" do
      dependent = build(
        :state_file_dependent,
        dob: (Time.now.beginning_of_day - 10.years).strftime("%Y-%m-%d")
        )
      expect(dependent.age).to be 9
    end
    it "when the birthday is tomorrow" do
      dependent = build(
        :state_file_dependent,
        dob: ((Time.now.beginning_of_day + 1.days) - 10.years).strftime("%Y-%m-%d")
      )
      expect(dependent.age).to be 9
    end
  end

end