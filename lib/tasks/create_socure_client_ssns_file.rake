require 'csv'

namespace :socure do
  desc "create a CSV file with client ids and de-crypted SSNs"
  task create_ssn_file: :environment do

    client_ids = Client.all.pluck(:id) # we actually need to find these from a CSV file from max
    attrs = %w{client_id ssn}

    file = CSV.open("#{Rails.root}/lib/tasks/results.csv", "wb") do |csv|
      csv << attrs

      client_ids.each do |id|
        csv << [id, Client.find(id).intake.primary_ssn]
      end
    end

    credentials = Aws::Credentials.new(
      Rails.application.credentials.dig(:aws, :access_key_id),
      Rails.application.credentials.dig(:aws, :secret_access_key),
      )

    Aws::S3::Client.new(region: 'us-east-1', credentials: credentials).put_object(
      key: "socure_test",
      body: "hello",
      bucket: "vita-min-demo-docs"
    )
  end

  task get_doc: :environment do
    download_path = "#{Rails.root}/lib/tasks/results.csv"

    credentials = Aws::Credentials.new(
      Rails.application.credentials.dig(:aws, :access_key_id),
      Rails.application.credentials.dig(:aws, :secret_access_key),
      )

    Aws::S3::Client.new(region: 'us-east-1', credentials: credentials).get_object(
      response_target: download_path,
      bucket: "vita-min-demo-docs",
      key: '0005su6iwdua0vti4h2gayqz8y3r',
      )
  end
end

# print the results into array and then convert into CSV and upload to lastpass
# rows = [["a1", "a2", "a3"],["b1", "b2", "b3", "b4"], ["c1", "c2", "c3"]]
# File.write("ss.csv", rows.map(&:to_csv).join)
#
#
# Hub form
# form
# html erb
# controller
# route
#