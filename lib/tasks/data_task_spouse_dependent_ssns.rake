require 'csv'

namespace :data_task_spouse_dependent_ssns do
  desc "create file of unhashed SSNs and respective unhashed spouse and dependent SSNs"
  task create_file: :environment do
    file_in = File.open("#{Rails.root}/tmp/test.csv")
    in_data = CSV.read(file_in, headers: true)
    client_ids = in_data.map { |row| row['client_id'].to_i }

    temp_file = Tempfile.open(%w[temp_file .csv], "tmp/")
    CSV.open(Rails.root.join(temp_file.path), 'wb') do |csv|
      csv << %w{client_id type ssn}

      Client.where(id: client_ids).includes(intake: [:dependents]).find_in_batches do |batch|
        batch.each do |client|
          next unless client.present? && client&.intake.present?
          intake = client&.intake
          csv << [client.id, "primary", intake.primary_ssn]
          csv << [client.id, "spouse", intake.spouse_ssn] if intake.spouse_ssn.present?
          intake.dependents.each do |dependent|
            csv << [client.id, "dependent-##{dependent.id}", dependent.ssn] if dependent.ssn.present?
          end
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
    temp_file.close
    temp_file.unlink
  end
end