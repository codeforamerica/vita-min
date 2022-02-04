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

      puts "Gonna screenshot: #{@test_cases.select { |tc| tc.screenshot }.length}"
    end
  end

  class TriageFlowTestCase
    attr_reader :row
    attr_accessor :screenshot

    def initialize(row)
      @row = row
    end

    def context_name
      Hash[row.reject { |k, v| k == 'service' || v == 'skip' }].values.compact.join(' - ')
    end

    def test_name
      "shows the #{final_page} page"
    end

    def rspec_metadata
      screenshot ? { flow_explorer_screenshot_i18n_friendly: true } : { }
    end

    def final_page
      case row['service']
      when 'We have two free options that may work for you!'
        Questions::TriageGyrExpressController
      when 'We recommend filing with our free File Myself option!'
        Questions::TriageReferralController
      when 'We recommend filing for free with GetYourRefund!'
        Questions::TriageGyrController
      when 'We recommend filing with our Express option!'
        Questions::TriageExpressController
      when 'Unfortunately, it looks like you do not qualify for our free service.'
        Questions::TriageDoNotQualifyController
      end
    end

    def expected_controllers
      [
        Questions::TriageIncomeLevelController,
        (Questions::TriageStartIdsController unless row['id_type'] == 'skip'),
        (Questions::TriageIdTypeController unless row['id_type'] == 'skip'),
        (Questions::TriageDocTypeController unless row['doc_type'] == 'skip'),
        (Questions::TriageBacktaxesYearsController unless row['filed_past_years'] == 'skip'),
        (Questions::TriageAssistanceController unless row['assistance_options'] == 'skip'),
        (Questions::TriageIncomeTypesController unless row['income_type_options'] == 'skip'),
        final_page
      ].compact
    end

    def expected_paths
      expected_controllers.map(&:to_path_helper)
    end

    def income
      row['income']
    end

    def filing_status
      answer = row['filing_status']
      if answer == 'any answer'
        'single'
      else
        answer
      end
    end

    def id_type
      row['id_type']
    end

    def doc_type
      answer = row['doc_type']
      if answer == 'any answer'
        'all_copies'
      else
        answer
      end
    end

    def filed_past_years
      answer = row['filed_past_years']
      return if answer == 'skip'

      case answer
      when '2021 yes/no, any prior no'
        [2021]
      when '2021 no, all prior yes'
        [2020, 2019, 2018]
      when '2021 yes, all prior yes'
        [2021, 2020, 2019, 2018]
      end
    end

    def assistance_options
      answer = row['assistance_options']
      answer == 'yes' ? ['in_person'] : ['none_of_the_above']
    end

    def income_type_options
      answer = row['income_type_options']
      answer == 'yes' ? ['farm'] : ['none_of_the_above']
    end
  end

  TriageFlowTestHelper.new.test_cases.each do |test_case|
    context test_case.context_name do
      it test_case.test_name, test_case.rspec_metadata do
        pages = answer_gyr_triage_questions(
          income_level: test_case.income,
          filing_status: test_case.filing_status,
          id_type: test_case.id_type,
          doc_type: test_case.doc_type,
          filed_past_years: test_case.filed_past_years,
          income_type_options: test_case.income_type_options,
          assistance_options: test_case.assistance_options
        )

        expect(pages).to eq(test_case.expected_paths)
      end
    end
  end
end
