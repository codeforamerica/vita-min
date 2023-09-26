require 'csv'

namespace :socure do
  desc "create socure CSV file"
  task create_client_file: :environment do
    # client_ids = []
    # file_in = File.open("#{Rails.root}/lib/tasks/client_ids.csv")
    # in_data = CSV.read(file_in, headers: true)
    # in_data.each do |record|
    #   record = record.to_ary
    #   client_id = record[0][1]&.strip
    #   client_ids << client_id.to_i
    # end

    client_ids = Client.joins(:efile_submissions).where("efile_submissions.created_at >= ?", Date.parse('2022-05-15')).pluck(:id).uniq

    temp_file = Tempfile.open(%w[temp_test .csv], "tmp/")
    CSV.open(Rails.root.join(temp_file.path), 'wb') do |csv|
      csv << %w{client_id ssn}

      client_ids.each do |id|
        csv << [id, Client.find_by_id(id)&.intake&.primary_ssn]
      end
    end

    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join(temp_file.path), 'rb'),
      filename: "socure_client_results.csv",
      content_type: "text/csv"
    )

    puts "*******FILE KEY: #{blob.key}"
    puts blob.inspect
    temp_file.unlink
  end

  # provide a protected CSV via Lastpass of unhashed primary SSNs and respective unhashed spouse and dependent SSNs
  # These will be for 70k specific clients. Reach out to Max for the list of client ids
  desc "create file of unhashed SSNs and respective unhashed spouse and dependent SSNs"
  task create_file: :environmetn do
    client_ids = Client.all.pluck(:id)
    file_in = File.open("#{Rails.root}/lib/tasks/client_ids.csv")
    #process the file

    temp_file = Tempfile.open(%w[temp_file .csv], "tmp/")
    CSV.open(Rails.root.join(temp_file.path), 'wb') do |csv|
      # headers
      csv << %w{client_id ssn type}

      # rows
      client_ids.each do |id|
        intake = Client.find_by_id(id)&.intake
        csv << [id, intake.primary_ssn, "primary"]
        csv << [id, intake.spouse_ssn, "spouse"] if intake.spouse_ssn.present?
        intake.dependents.each do |dependent|
          csv << [id, dependent.ssn, "dependent"]
        end

      end
    end

  end
end

