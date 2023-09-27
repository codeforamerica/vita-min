require 'csv'

namespace :data_task_spouse_dependent_ssns do
  desc "create file of unhashed SSNs and respective unhashed spouse and dependent SSNs"
  task create_file: :environment do
    file_in = File.open("#{Rails.root}/tmp/ca_ids_for_eng_nov02.csv")
    in_data = CSV.read(file_in, headers: true)
    client_ids = []
    in_data.each do |record|
      record = record.to_ary
      client_id = record[0][1]&.strip
      client_ids << client_id.to_i
    end

    temp_file = Tempfile.open(%w[temp_file .csv], "tmp/")
    CSV.open(Rails.root.join(temp_file.path), 'wb') do |csv|
      csv << %w{client_id ssn type}

      client_ids.each do |id|
        client = Client.find_by_id (id)
        next unless client || client&.intake
        intake = client&.intake
        csv << [id, "primary", intake.primary_ssn]
        csv << [id, "spouse", intake.spouse_ssn] if intake.spouse_ssn.present?
        intake.dependents.each do |dependent|
          csv << [id, "dependent", dependent.ssn] if dependent.ssn.present?
        end
      end
    end

    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join(temp_file.path), 'rb'),
      filename: "spouse_dependents_results.csv",
      content_type: "text/csv"
    )

    puts "*******FILE KEY: #{blob.key}"
    puts blob.inspect
    puts "***********blob URL:"
    temp_file.unlink
  end
end

