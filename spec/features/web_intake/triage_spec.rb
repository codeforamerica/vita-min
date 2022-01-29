require "rails_helper"

require 'csv'

RSpec.feature "triage flow", :flow_explorer_screenshot_i18n_friendly do
  class TriageFlowTestHelper
    def self.read_csv
      csv = CSV.read(File.join(__dir__, 'triage-results.csv'), headers: true)
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

      rows
    end

    attr_reader :row

    def initialize(row)
      @row = row
    end

    def context_name
      Hash[row.reject { |k, v| k == 'service' || v == 'skip' }].values.compact.join(' - ')
    end

    def test_name
      "shows the #{final_page} page"
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

    def build_expectation
      [
        Questions::TriageIncomeLevelController,
        (Questions::TriageStartIdsController unless row['id_type'] == 'skip'),
        (Questions::TriageIdTypeController unless row['id_type'] == 'skip'),
        (Questions::TriageDocTypeController unless row['doc_type'] == 'skip'),
        (Questions::TriageBacktaxesYearsController unless row['filed_past_years'] == 'skip'),
        (Questions::TriageAssistanceController unless row['assistance_options'] == 'skip'),
        (Questions::TriageIncomeTypesController unless row['income_type_options'] == 'skip'),
        final_page
      ].compact.map(&:to_path_helper)
    end

    def income(answer)
      answer
    end

    def filing_status(answer)
      if answer == 'any answer'
        'single'
      else
        answer
      end
    end

    def doc_type(answer)
      if answer == 'any answer'
        'all_copies'
      else
        answer
      end
    end

    def filed_past_years(answer)
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

    def assistance_options(answer)
      answer == 'yes' ? ['in_person'] : ['none_of_the_above']
    end

    def income_type_options(answer)
      answer == 'yes' ? ['farm'] : ['none_of_the_above']
    end
  end

  TriageFlowTestHelper.read_csv.each do |row|
    helper = TriageFlowTestHelper.new(row)

    context helper.context_name do
      it helper.test_name do
        pages = answer_gyr_triage_questions(
          income_level: helper.income(row['income']),
          filing_status: helper.filing_status(row['filing_status']),
          id_type: row['id_type'],
          doc_type: helper.doc_type(row['doc_type']),
          filed_past_years: helper.filed_past_years(row['filed_past_years']),
          income_type_options: helper.income_type_options(row['income_type_options']),
          assistance_options: helper.assistance_options(row['assistance_options'])
        )

        expect(pages).to eq(helper.build_expectation)
      end
    end
  end
end
