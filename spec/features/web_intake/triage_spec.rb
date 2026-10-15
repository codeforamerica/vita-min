require "rails_helper"

require 'csv'

RSpec.feature "triage flow" do
  class TriageFlowTestHelper
    attr_accessor :test_cases

    def initialize(csv_file = 'triage-results.csv')
      csv = CSV.read(File.join(__dir__, csv_file), headers: true)
      column_names = csv.headers

      # remove rows that are all blanks
      csv = csv.reject { |row| row.to_h.values.uniq == [nil] }
      last_row = csv.first.to_h
      rows = []

      # carry over values from previous rows if some columns are blank
      csv.each do |row|
        this_row = Hash[row.to_h.map { |k, v| [k, v || last_row[k]] }]
        last_row = this_row
        rows << this_row
      end

      # for cells with "single or joint" for example, multiply the output rows
      # so there is both a 'single' and 'joint' row
      column_names.each do |column|
        new_rows = []
        rows.each do |row|
          row[column].split(' or ').each do |option|
            new_row = row.dup
            new_row[column] = option
            new_rows << new_row
          end
        end
        rows = new_rows
      end

      @test_cases = rows.map { |row| TriageFlowTestCase.new(row) }

      # flag certain test cases as `flow_explorer_screenshot` to ensure we screenshot
      # every page at least once, without having to run every single test case through headless chrome
      # (which takes like 10 minutes as of the writing of this comment)
      seen_controllers = {}
      @test_cases.each do |test_case|
        test_case.expected_controllers.each do |controller|
          unless seen_controllers[controller]
            test_case.screenshot = true
          end
          seen_controllers[controller] = true
        end
      end
    end
  end

  class TriageFlowTestCase
    attr_reader :row
    attr_accessor :screenshot

    def initialize(row)
      @row = row
    end

    def context_name
      Hash[row.reject { |k, v| k == 'service' || k == 'notes' || v == 'skip' }].values.compact.join(' - ')
    end

    def test_name
      "shows the #{final_page} page"
    end

    def rspec_metadata
      screenshot ? { flow_explorer_screenshot: true } : { }
    end

    def final_page
      case row['service'].strip
      when 'CTC-GYR'
        Questions::TriageGyrExpressController
      when 'DIY'
        Questions::TriageDiyController
      when 'GYR'
        Questions::TriageGyrController
      when 'GYR-DIY'
        Questions::TriageGyrDiyController
      when 'Does not qualify'
        Questions::TriageDoNotQualifyController
      end
    end

    def expected_controllers
      [
        Questions::EligibilityStateController,
        Questions::EligibilityHouseholdController,
        final_page
      ].compact
    end

    def expected_paths
      expected_controllers.map(&:to_path_helper)
    end

    def income_level
      row['triage_income_level'].strip
    end

    def vita_income_ineligible
      answer = row['triage_vita_income_ineligible'].strip
      answer == 'Yes' ? true : false
    end

    def service_preference
      row['service_preference'].strip
    end
  end

  TriageFlowTestHelper.new.test_cases.each do |test_case|
    context test_case.context_name do
      it test_case.test_name, test_case.rspec_metadata do
        pages = answer_gyr_triage_questions(
          triage_income_level: test_case.income_level,
          triage_vita_income_ineligible: test_case.vita_income_ineligible,
          service_preference: test_case.service_preference,
        )

        expect(pages).to eq(test_case.expected_paths)
      end
    end
  end

  context "when the client only checks W-2 wages and requests virtual VITA" do
    it "recommends GYR" do
      visit "/en/questions/eligibility-wages"
      select "$20,001 - $26,000", from: I18n.t("questions.eligibility_wages.edit.income_level.label")
      check I18n.t("questions.eligibility_wages.edit.vita_income_ineligible.options.w2s")
      choose "eligibility_wages_form_have_income_tax_documents_yes"
      click_on I18n.t("general.continue")

      choose "eligibility_state_form_service_preference_virtual_vita"
      click_on I18n.t("general.continue")

      choose I18n.t("questions.eligibility_household.edit.household_status.single")
      select "California", from: I18n.t("questions.eligibility_household.edit.residence_state")
      click_on I18n.t("general.continue")

      expect(page).to have_current_path(Questions::TriageGyrController.to_path_helper)
    end
  end
end
