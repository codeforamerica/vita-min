require "rails_helper"

describe StateFileDependent do
  describe "asking additional AZ senior questions" do
    it "asks more questions when a dependent is 65+ by the end of the tax year + grandparent + 12 months in home" do
      dependent = build(
        :state_file_dependent,
        dob: MultiTenantService.new(:statefile).end_of_current_tax_year.years_ago(65),
        months_in_home: 12,
        relationship: "GRANDPARENT"
      )

      expect(dependent.ask_senior_questions?).to be true
    end

    it "asks more questions when a dependent is 65+ by the end of the tax year + parent + 12 months in home" do
      dependent = create :state_file_dependent
      dependent.dob = MultiTenantService.new(:statefile).end_of_current_tax_year.years_ago(65)
      dependent.months_in_home = 12
      dependent.relationship = "PARENT"

      expect(dependent.ask_senior_questions?).to be true
    end

    it "does NOT ask more questions when a dependent is 65+ AFTER the end of the tax year + grandparent + 12 months in home" do
      dependent = create :state_file_dependent
      dependent.dob = DateTime.new(2024, 1, 1).years_ago(65)
      dependent.months_in_home = 12
      dependent.relationship = "GRANDPARENT"

      expect(dependent.ask_senior_questions?).to be false
    end

    it "does NOT ask more questions when a dependent is 65+ by the end of the tax year + NOT parent or grandparent + 12 months in home" do
      dependent = create :state_file_dependent
      dependent.dob = MultiTenantService.new(:statefile).end_of_current_tax_year.years_ago(65)
      dependent.months_in_home = 12
      dependent.relationship = "DAUGHTER"

      expect(dependent.ask_senior_questions?).to be false
    end

    it "does NOT ask more questions when a dependent is 65+ by the end of the tax year + grandparent + LESS THAN 12 months in home" do
      dependent = create :state_file_dependent
      dependent.dob = MultiTenantService.new(:statefile).end_of_current_tax_year.years_ago(65)
      dependent.months_in_home = 11
      dependent.relationship = "GRANDPARENT"

      expect(dependent.ask_senior_questions?).to be false
    end
  end
end