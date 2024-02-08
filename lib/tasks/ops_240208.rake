namespace :ops_240208 do
  desc "Ops scripts for 240208"
  task "delete_invalid_intakes" => :environment do
    # EFile accidentally pointed at our production servers before launch, so there is some trash test
    # data in here. Burn it!
    date_threshold = "2024-02-07"
    EfileSubmission.where(data_source_type: ["StateFileAzIntake", "StateFileNyIntake"]).where("created_at < ?", date_threshold).destroy_all
    StateFileNyIntake.where("created_at < ?", date_threshold).destroy_all
    StateFileAzIntake.where("created_at < ?", date_threshold).destroy_all
  end
end