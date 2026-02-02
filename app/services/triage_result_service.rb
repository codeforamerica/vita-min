class TriageResultService
  attr_reader :intake

  def initialize(intake)
    @intake = intake
  end

  def after_income_levels_triaged_route
    if intake.triage_income_level_zero? && intake.service_preference_diy?
      route_to_diy
    elsif intake.triage_income_level_1_to_69000? || intake.triage_income_level_69001_to_89000?
      if intake.triage_vita_income_ineligible_yes? || intake.service_preference_diy?
        route_to_diy
      else
        route_to_gyr
      end
    else
      route_to_gyr
    end
  end

  private

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
