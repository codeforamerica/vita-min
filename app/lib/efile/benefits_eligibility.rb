module Efile
  class BenefitsEligibility
    EITC_UPPER_LIMIT_JOINT = 17_550
    EITC_UPPER_LIMIT_SINGLE = 11_610

    SIMPLIFIED_FILING_UPPER_LIMIT_JOINT = 25_100
    SIMPLIFIED_FILING_UPPER_LIMIT_SINGLE = 12_550

    attr_accessor :year, :eligible_filer_count, :dependents, :intake, :tax_return
    def initialize(tax_return:, dependents:)
      @tax_return = tax_return
      @year = tax_return.year
      @intake = tax_return.intake
      @dependents = dependents
      @eligible_filer_count = rrc_eligible_filer_count
    end

    def eip1_amount
      return 0 unless year == 2020

      sum = 1200 * eligible_filer_count
      sum += dependents.map { |d| Efile::DependentEligibility::EipOne.new(d, year).benefit_amount }.sum
      sum
    end

    def outstanding_eip1
      [eip1_amount - intake.eip1_amount_received, 0].max
    end

    def eip2_amount
      return 0 unless year == 2020

      sum = 600 * eligible_filer_count
      sum += dependents.map { |d| Efile::DependentEligibility::EipTwo.new(d, year).benefit_amount }.sum
      sum
    end

    def outstanding_eip2
      [eip2_amount - intake.eip2_amount_received, 0].max
    end

    def eip3_amount
      sum = 1400 * eligible_filer_count
      sum += dependents.map { |d| Efile::DependentEligibility::EipThree.new(d, year).benefit_amount }.sum
      sum
    end

    def eip3_amount_received
      intake.eip3_amount_received || 0
    end

    def outstanding_eip3
      [eip3_amount - eip3_amount_received, 0].max
    end

    def ctc_amount
      return 0 if year == 2020

      dependents.map { |d| Efile::DependentEligibility::ChildTaxCredit.new(d, year).benefit_amount }.sum
    end

    def outstanding_ctc_amount
      [ctc_amount - advance_ctc_amount_received, 0].max
    end

    def advance_ctc_amount_received
      intake.advance_ctc_amount_received || 0
    end

    # A quick calculation for ODC (Other Dependents Credit) which does not get paid out to our filers,
    # but is needed for the 8812 calculation.
    def odc_amount
      return nil if intake.home_location_puerto_rico?
      return 0 if year == 2020

      dependents.count { |d| !d.qualifying_ctc? && (d.qualifying_child? || d.qualifying_relative?) } * 500
    end

    def outstanding_recovery_rebate_credit
      if year == 2020
        return nil unless intake.eip1_amount_received && intake.eip2_amount_received

        outstanding_eip1 + outstanding_eip2
      elsif year == 2021
        return nil unless intake.eip3_amount_received

        outstanding_eip3
      end
    end

    def claimed_recovery_rebate_credit
      return nil if intake.home_location_puerto_rico?
      return 0 if intake.claim_owed_stimulus_money_no?

      outstanding_recovery_rebate_credit
    end

    def eitc_amount
      # EITC amount = [phase-in function, plateau amount, phase-out function].min
      # where phase-in function = earned-income amount * phase-in rate
      # But b/c of simplified filing rules, those above the phase out threshold cannot use the tool
      # so we are not including the phase-out function but keep in mind this might change next year
      return nil unless intake.is_ctc? && claiming_and_qualified_for_eitc?

      earned_income = intake.w2s.sum(&:wages_amount).to_f

      case dependents.count { |d| d.qualifying_eitc? && (d.qualifying_child? || d.qualifying_relative?) }
      when 0
        [(0.153 * earned_income), 1502].min.round
      when 1
        [(0.34 * earned_income), 3618].min.round
      when 2
        [(0.4 * earned_income), 5980].min.round
      else
        [(0.45 * earned_income), 6728].min.round
      end
    end

    def claiming_and_qualified_for_eitc?
      intake.claim_eitc_yes? && qualified_for_eitc_pre_w2s? && intake.w2s.any? && !disqualified_for_eitc_due_to_income?
    end

    def claiming_and_qualified_for_eitc_pre_w2s?
      intake.claim_eitc_yes? && qualified_for_eitc_pre_w2s?
    end

    def qualified_for_eitc_pre_w2s?
      intake.exceeded_investment_income_limit_no? &&
        eitc_qualifications_passes_age_test? &&
        eitc_qualifications_passes_tin_type_test?
    end

    def youngish_without_eitc_dependents?
      age_at_end_of_tax_year(intake.primary) < 24 && age_at_end_of_tax_year(intake.primary) >= 18 && dependents.none?(&:qualifying_eitc?)
    end

    def filers_younger_than_twenty_four?
      intake.filers.all? { |filer| age_at_end_of_tax_year(filer) < 24 }
    end

    def disqualified_for_eitc_due_to_income?
      no_qcs && (intake.had_disqualifying_non_w2_income_yes? || over_income_threshold)
    end

    private

    def no_qcs
      intake.dependents.none?(&:qualifying_eitc?)
    end

    def over_income_threshold
      return false unless intake.total_wages_amount

      if intake.filing_jointly?
        intake.total_wages_amount >= EITC_UPPER_LIMIT_JOINT
      else
        intake.total_wages_amount >= EITC_UPPER_LIMIT_SINGLE
      end
    end

    def eitc_qualifications_passes_age_test?
      return true unless filers_younger_than_twenty_four?
      return true if dependents.any?(&:qualifying_eitc?)

      if intake.former_foster_youth_yes? || intake.homeless_youth_yes?
        age_at_end_of_tax_year(intake.primary) >= 18
      elsif intake.not_full_time_student_yes? || intake.full_time_student_less_than_four_months_yes?
        age_at_end_of_tax_year(intake.primary) >= 19
      else
        false
      end
    end

    def age_at_end_of_tax_year(filer)
      tax_return.year - filer.birth_date.year
    end

    def eitc_qualifications_passes_tin_type_test?
      intake.filers.all? { |filer| filer.tin_type == 'ssn' }
    end

    def rrc_eligible_filer_count
      raise unless tax_return.filing_status.in?(%w[single married_filing_jointly head_of_household])

      # if one spouse is a member of the armed forces, both qualify for benefits
      return intake.filers.count if intake.filers.any? { |filer| filer.active_armed_forces == 'yes' }

      # only filers with SSNs (valid for employment) are eligible for RRC
      intake.filers.count { |filer| filer.tin_type == 'ssn' }
    end
  end
end
