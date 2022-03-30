class TriageResultService
  attr_reader :intake

  def initialize(intake)
    @intake = intake
  end

  def after_income_levels
    if intake.triage_income_level_zero?
      if intake.need_itin_help_yes?
        return route_to_gyr
      elsif intake.need_itin_help_no?
        return route_to_gyr_ctc_choice
      end
    end

    if inside_ctc_income_limit?
      if intake.need_itin_help_yes?
        if intake.triage_vita_income_ineligible_no?
          return route_to_gyr
        elsif intake.triage_vita_income_ineligible_yes?
          return route_to_does_not_qualify
        end
      elsif intake.need_itin_help_no?
        if intake.triage_vita_income_ineligible_no?
          return route_to_gyr_ctc_choice
        elsif intake.triage_vita_income_ineligible_yes?
          return route_to_diy
        end
      end
    end

    if intake.triage_filing_status_single? && intake.triage_income_level_12500_to_25000?
      if intake.need_itin_help_yes?
        if intake.triage_vita_income_ineligible_no?
          return route_to_gyr
        elsif intake.triage_vita_income_ineligible_yes?
          return route_to_does_not_qualify
        end
      elsif intake.need_itin_help_no?
        if intake.triage_vita_income_ineligible_no?
          return route_to_gyr_diy_choice
        elsif intake.triage_vita_income_ineligible_yes?
          return route_to_diy
        end
      end
    end

    if intake.triage_income_level_25000_to_40000? || intake.triage_income_level_40000_to_65000?
      if intake.need_itin_help_yes?
        if intake.triage_vita_income_ineligible_no?
          return route_to_gyr
        elsif intake.triage_vita_income_ineligible_yes?
          return route_to_does_not_qualify
        end
      elsif intake.need_itin_help_no?
        return route_to_diy
      end
    end

    if intake.triage_income_level_65000_to_73000?
      return route_to_diy
    end

    if intake.triage_income_level_over_73000?
      return route_to_does_not_qualify
    end
  end

  private

  def inside_ctc_income_limit?
    intake.triage_income_level_1_to_12500? ||
      (intake.triage_filing_status_jointly? && intake.triage_income_level_12500_to_25000?)
  end

  def route_to_does_not_qualify
    Questions::TriageDoNotQualifyController.to_path_helper
  end

  def route_to_diy
    Questions::TriageDiyController.to_path_helper
  end

  def route_to_gyr
    Questions::TriageGyrController.to_path_helper
  end

  def route_to_gyr_ctc_choice
    Questions::TriageGyrExpressController.to_path_helper
  end

  def route_to_gyr_diy_choice
    Questions::TriageGyrDiyController.to_path_helper
  end

  def route_to_ctc
    Questions::TriageExpressController.to_path_helper
  end
end
