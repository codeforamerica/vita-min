require 'csv'
namespace :intake do
  desc "Creates a CSV report of critical tracking fields for specific intakes"
  task :create_report, [:intake_ids] => :environment do |_task, args|
    intake_ids = args.intake_ids.split(";").map(&:to_i)
    intakes = Intake.where(id: intake_ids)
    headers = %i{
      id
      created_at
      updated_at
      anonymous
      email_address
      completed_at
      phone_number
      preferred_name
      referrer
      source
      state_of_residence
      zip_code
      intake_ticket_id
      intake_ticket_requester_id
      visitor_id
      zendesk_group_id
    }
    filename = Rails.root.join("tmp", "intake_report.csv")
    puts "*"*80
    puts "Writing report for intake_ids: #{intake_ids} to filename: #{filename}"
    puts "*"*80
    CSV.open(filename, "w") do |csv|
      csv << headers
      intakes.pluck(*headers).each { |row| csv << row }
    end
  end
end
