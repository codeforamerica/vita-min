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

      # flag certain test cases as `flow_explorer_screenshot_i18n_friendly` to ensure we screenshot
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
      screenshot ? { flow_explorer_screenshot_i18n_friendly: true } : { }
    end

    def final_page
      case row['service'].strip
      when 'Express-GYR'
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
        Questions::TriageIncomeLevelController,
        final_page
      ].compact
    end

    def expected_paths
      expected_controllers.map(&:to_path_helper)
    end

    def need_itin_help
      answer = row['need_itin_help'].strip
      answer == 'Yes' ? true : false
    end

    def income_level
      row['triage_income_level'].strip
    end

    def filing_status
      row['triage_filing_status'].strip
    end

    def vita_income_ineligible
      answer = row['triage_vita_income_ineligible'].strip
      answer == 'Yes' ? true : false
    end
  end

  TriageFlowTestHelper.new.test_cases.each do |test_case|
    context test_case.context_name do
      it test_case.test_name, test_case.rspec_metadata do
        pages = answer_gyr_triage_questions(
          need_itin: test_case.need_itin_help,
          triage_income_level: test_case.income_level,
          triage_filing_status: test_case.filing_status,
          triage_filing_frequency: "some_years",
          triage_vita_income_ineligible: test_case.vita_income_ineligible,
        )

        expect(pages).to eq(test_case.expected_paths)
      end
    end
  end
end
