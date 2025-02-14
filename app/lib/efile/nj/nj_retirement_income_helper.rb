module Efile
  module Nj
    class NjRetirementIncomeHelper
      def initialize(intake)
        @intake = intake
      end

      def total_eligible_nonretirement_income
        total_income = 0
        eligible_ssn = []
        if primary_62_and_older?
          eligible_ssn.push(@intake.primary.ssn)
        end
        if @intake.spouse_birth_date.present? && spouse_62_and_older?
          eligible_ssn.push(@intake.spouse.ssn)
        end
        @intake.state_file_w2s.each do |w2|
          if w2.employee_ssn.in?(eligible_ssn)
            total_income += w2.state_wages_amount.to_i
          end
        end
        @intake.direct_file_json_data.interest_reports.each do |form1099|
          sanitized_recipient_tin = form1099.recipient_tin.tr("-", "")
          if sanitized_recipient_tin.in?(eligible_ssn)
            total_income += form1099.interest_on_government_bonds.to_i
          end
        end
        total_income
      end

      def primary_62_and_older?
        @intake.calculate_age(@intake.primary_birth_date, inclusive_of_jan_1: true) >= 62
      end

      def spouse_62_and_older?
        @intake.calculate_age(@intake.spouse_birth_date, inclusive_of_jan_1: true) >= 62 
      end

      def eligible?
        if @intake.spouse_birth_date.present?
          return false unless spouse_62_and_older? || primary_62_and_older?
        elsif !primary_62_and_older?
          return false
        end
        return false if @intake.calculator.lines[:NJ1040_LINE_15].value > 3_000
        return false if @intake.calculator.lines[:NJ1040_LINE_27].value > 150_000
        return false if @intake.calculator.lines[:NJ1040_LINE_28A].value > calculate_maximum_exclusion(@intake.calculator.lines[:NJ1040_LINE_27].value)

        true
      end

      def calculate_maximum_exclusion(total_income)
        if @intake.filing_status_mfs?
          case total_income
          when 0..100_000
            50_000
          when 100_001..125_000
            (0.25 * total_income).round
          when 125_001..150_000
            (0.125 * total_income).round
          else
            0
          end
        elsif @intake.filing_status_mfj?
          case total_income
          when 0..100_000
            100_000
          when 100_001..125_000
            (0.5 * total_income).round
          when 125_001..150_000
            (0.25 * total_income).round
          else
            0
          end
        else
          case total_income
          when 0..100_000
            75_000
          when 100_001..125_000
            (0.375 * total_income).round
          when 125_001..150_000
            (0.1875 * total_income).round
          else
            0
          end
        end
      end
    end
  end
end