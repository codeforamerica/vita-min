# run command =>
# START_DATE=YYYY-MM-DD END_DATE=YYYY-MM-DD CHUNK_SIZE=5000 bundle exec rake create_campaign_contacts:backfill
# consider increasing the job workers before running this

namespace :create_campaign_contacts do
  desc "Enqueue backfill campaign_contacts for records created between START_DATE and END_DATE (YYYY-MM-DD)"
  task backfill: :environment do
    chunk = ENV.fetch("CHUNK_SIZE", "5000").to_i
    window_start = Date.parse(ENV.fetch("START_DATE")).beginning_of_day
    window_end = Date.parse(ENV.fetch("END_DATE")).end_of_day

    # StateFile intakes
    StateFile::StateInformationService.state_intake_classes.each do |klass|
      sf_scope = klass.contactable.where(created_at: window_start..window_end)
      enqueue_in_id_ranges(sf_scope, chunk) do |min_id, max_id|
        Campaign::SyncContacts::BackfillStateFileIntakesJob.perform_later(klass.name, min_id, max_id, window_start.to_date, window_end.to_date)
      end
    end

    # Signups
    signup_scope = Signup.where(created_at: window_start..window_end)
    enqueue_in_id_ranges(signup_scope, chunk) do |min_id, max_id|
      Campaign::SyncContacts::BackfillSignupsJob.perform_later(min_id, max_id, window_start.to_date, window_end.to_date)
    end

    # GYR-intakes
    gyr_scope = Intake::GyrIntake.contactable.where(created_at: window_start..window_end)
    enqueue_in_id_ranges(gyr_scope, chunk) do |min_id, max_id|
      Campaign::SyncContacts::BackfillGyrIntakesJob.perform_later(min_id, max_id, window_start.to_date, window_end.to_date)
    end
  end
end

def enqueue_in_id_ranges(scope, chunk)
  min_id = scope.minimum(:id)
  max_id = scope.maximum(:id)
  return if min_id.nil? || max_id.nil?

  min_id.step(max_id, chunk) do |start_id|
    end_id = [start_id + chunk - 1, max_id].min
    yield(start_id, end_id)
  end
end
