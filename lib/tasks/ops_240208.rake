namespace :ops_240208 do
  desc "Ops scripts for 240208"
  task "delete_invalid_intakes" => :environment do
    # EFile accidentally pointed at our production servers before launch, so there is some trash test
    # data in here. Burn it!
    date_threshold = "2024-02-07"
    StateFile::StateInformationService.state_intake_classes.flat_map do |class_object|
      EfileSubmission.where(data_source_type: class_object).where("created_at < ?", date_threshold).destroy_all
      class_object.where("created_at < ?", date_threshold).destroy_all
    end
  end
end