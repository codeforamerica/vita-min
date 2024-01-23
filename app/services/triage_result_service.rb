class TriageResultService
  attr_reader :intake

  def initialize(intake)
    @intake = intake
  end

  def after_income_levels_triaged_route
    if intake.triage_income_level_zero?
      return route_to_gyr
    elsif income_level_1_to_66000?
      if intake.triage_vita_income_ineligible_yes?
        route_to_diy
      else
        route_to_gyr_diy_choice
      end
    elsif intake.triage_income_level_66000_to_79000?
      route_to_diy
    elsif intake.triage_income_level_over_79000?
      route_to_does_not_qualify
    end
  end

  private

  def income_level_1_to_66000?
    intake.triage_income_level_1_to_12500? || intake.triage_income_level_12500_to_25000? || intake.triage_income_level_25000_to_40000? || intake.triage_income_level_40000_to_66000?
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

  def route_to_gyr_diy_choice
    Questions::TriageGyrDiyController.to_path_helper
  end
end
