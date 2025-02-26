module Efile
  module Nj
    class NjRetirementIncomeHelper

      attr_accessor :non_military_1099rs
      def initialize(intake)
        @intake = intake
        @non_military_1099rs = @intake.state_file1099_rs.select do |state_file_1099r|
          state_file_1099r.state_specific_followup.present? && state_file_1099r.state_specific_followup.income_source_other?
        end
      end

      def total_eligible_nonmilitary_1099r_income
        total_eligible_income = 0
        eligible_ssns = []
        if line_28a_primary_eligible?
          eligible_ssns.push(@intake.primary.ssn)
        end
        if @intake.spouse_birth_date.present? && line_28a_spouse_eligible?
          eligible_ssns.push(@intake.spouse.ssn)
        end

        @non_military_1099rs.each do |non_military_1099r|
          if non_military_1099r.recipient_ssn.in?(eligible_ssns)
            total_eligible_income += non_military_1099r.taxable_amount.round
          end
        end

        total_eligible_income
      end

      def total_eligible_nonretirement_income
        total_income = 0
        eligible_ssns = []
        if primary_62_and_older?
          eligible_ssns.push(@intake.primary.ssn)
        end
        if @intake.spouse_birth_date.present? && spouse_62_and_older?
          eligible_ssns.push(@intake.spouse.ssn)
        end
        @intake.state_file_w2s.each do |w2|
          if w2.employee_ssn.in?(eligible_ssns)
            total_income += w2.state_wages_amount.to_i
          end
        end
        @intake.direct_file_json_data.interest_reports.each do |interest_report|
          sanitized_recipient_tin = interest_report.recipient_tin.delete("-")
          if sanitized_recipient_tin.in?(eligible_ssns)
            total_income += (interest_report.amount_1099&.round || 0) + (interest_report.amount_no_1099&.round || 0)
          end
        end
        total_income
      end

      def primary_62_and_older?
        @intake.calculate_age(@intake.primary_birth_date, inclusive_of_jan_1: false) >= 62
      end

      def spouse_62_and_older?
        @intake.calculate_age(@intake.spouse_birth_date, inclusive_of_jan_1: false) >= 62 
      end

      def line_28b_eligible?(line_15, line_27, line_28a)
        if @intake.spouse_birth_date.present?
          spouse_or_primary_is_age_eligible = spouse_62_and_older? || primary_62_and_older?
          return false unless spouse_or_primary_is_age_eligible
        elsif !primary_62_and_older?
          return false
        end
        return false if line_15 > 3_000
        return false if line_27 > 150_000
        return false if line_28a > calculate_maximum_exclusion(line_27, line_27)

        true
      end

      def line_28a_eligible?(line_27)
        return false if line_27 > 150_000
        if @intake.spouse_birth_date.present?
          return false unless line_28a_primary_eligible? || line_28a_spouse_eligible?
        else
          return false unless line_28a_primary_eligible?
        end
        true
      end

      def line_28a_primary_eligible?
        primary_62_and_older? || @intake.primary_disabled_yes? || @intake.direct_file_data.is_primary_blind?
      end

      def line_28a_spouse_eligible?
        spouse_62_and_older? || @intake.spouse_disabled_yes? || @intake.direct_file_data.is_spouse_blind?
      end

      def calculate_maximum_exclusion(total_income, income_for_exclusion)
        if @intake.filing_status_mfs?
          case total_income
          when 0..100_000
            50_000
          when 100_001..125_000
            (0.25 * income_for_exclusion).round
          when 125_001..150_000
            (0.125 * income_for_exclusion).round
          else
            0
          end
        elsif @intake.filing_status_mfj?
          case total_income
          when 0..100_000
            100_000
          when 100_001..125_000
            (0.5 * income_for_exclusion).round
          when 125_001..150_000
            (0.25 * income_for_exclusion).round
          else
            0
          end
        else
          case total_income
          when 0..100_000
            75_000
          when 100_001..125_000
            (0.375 * income_for_exclusion).round
          when 125_001..150_000
            (0.1875 * income_for_exclusion).round
          else
            0
          end
        end
      end


    end
  end
end