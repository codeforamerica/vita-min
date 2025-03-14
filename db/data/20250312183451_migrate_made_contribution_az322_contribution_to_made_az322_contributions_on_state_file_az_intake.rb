# frozen_string_literal: true

class MigrateMadeContributionAz322ContributionToMadeAz322ContributionsOnStateFileAzIntake < ActiveRecord::Migration[7.1]
  def up
    et = Time.find_zone('America/New_York')
    time_of_release_of_contribution_update = et.parse('2025-02-07 18:26:00')
    az_intakes_with_contributions_created_before_feb_7 = StateFileAzIntake
                                        .left_joins(:efile_submissions)
                                        .left_joins(:az322_contributions)
                                        .where('state_file_az_intakes.created_at < ?', time_of_release_of_contribution_update) # make this time more specific
                                        .where.not(az322_contributions: { id: nil })

    Sentry.capture_message "There are #{az_intakes_with_contributions_created_before_feb_7.count} intakes created before February 7, 2025 at 6:26 PM EST that have az322 contributions"
    az_intakes_with_contributions_created_before_feb_7.update_all(made_az322_contributions: 1)
    Sentry.capture_message "There are #{az_intakes_with_contributions_created_before_feb_7.count} intakes created before February 7, 2025 that have been updated to register az322 contributions"

    submitted_az_intakes_without_contributions_created_before_feb_7 = StateFileAzIntake
                                                      .left_joins(:efile_submissions)
                                                      .left_joins(:az322_contributions)
                                                      .where.not(efile_submissions: { id: nil })
                                                      .where('state_file_az_intakes.created_at < ?', time_of_release_of_contribution_update)
                                                      .where(az322_contributions: { id: nil })

    Sentry.capture_message "There are #{az_intakes_with_contributions_created_before_feb_7.count} intakes created before February 7, 2025 at 6:26 PM that do not have az322 contributions"
    submitted_az_intakes_without_contributions_created_before_feb_7.update_all(made_az322_contributions: 2)
    Sentry.capture_message "There are #{az_intakes_with_contributions_created_before_feb_7.count} intakes that were submitted & created before February 7, 2025 at 6:26 PM EST that have been updated to not register az322 contributions"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
