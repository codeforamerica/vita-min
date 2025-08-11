#!/usr/bin/env ruby

require_relative "../config/environment"
require 'json'

class CopyToNewS3Bucket < Thor
  # Exits with error instead of status 0
  # issue: https://github.com/rails/thor/issues/244
  # code: https://github.com/rails/thor/blob/v1.0.0/lib/thor/base.rb#L521
  def self.exit_on_failure?
    true
  end

  desc 'copy', 'Copies only the archived intakes\'s submission pdfs to a new bucket'
  def copy
    unless Rails.env.production? || Rails.env.staging? || Rails.env.demo? || Rails.env.heroku?
      say "Please run this from deployed environments that utilize AWS S3 buckets"
    end

    say "Finding all archived intakes and copying over the submission_pdfs to new bucket...", :green
    intake_to_key_hash = {}

    # Default batch 1000 https://apidock.com/rails/ActiveRecord/Batches/find_in_batches
    StateFileArchivedIntake.find_in_batches.with_index do |intakes, batch|
      say "Processing group ##{batch}..."

      intakes.each do |intake|
        key = intake.submission_pdf&.blob&.key

        if key.nil?
          # add key to some log out so that we can track which ones do not have
          say "Intake #{intake.id} does not have a submission_pdf blob key"
          next
        end
        intake_to_key_hash[intake.id] = key
        copy_submission_pdfs_to_new_s3_bucket(key)
      end
    end

    say "Uploading the json containing intakes-key hash...", :green
    upload_json_to_s3(intake_to_key_hash)
    say "Success!", :green
  rescue
    say "Something went wrong"
  end

  private

  def copy_submission_pdfs_to_new_s3_bucket(key)
    `aws s3 cp s3://#{source_bucket}/#{key} s3://#{destination_bucket}/#{key}`
  rescue
    # Silently move on if something happens during copying?
    say e.message
  end

  def source_bucket
    case Rails.env
    when 'production'
      'vita-min-prod-docs'
    when 'staging'
      'vita-min-staging-docs'
    when 'demo'
      'vita-min-demo-docs'
    when 'heroku'
      'vita-min-heroku-docs'
    else
      'vita-min-demo-docs'
    end
  end

  def destination_bucket
    case Rails.env
    when 'production'
      'vita-min-archived-intakes-submission-pdfs'
    when 'staging'
      'vita-min-staging-archived-intakes-submission-pdfs'
    when 'demo'
      'vita-min-demo-archived-intakes-submission-pdfs'
    when 'heroku'
      'vita-min-heroku-archived-intakes-submission-pdfs'
    else
      'vita-min-demo-archived-intakes-submission-pdfs'
    end
  end

  def upload_json_to_s3(hash_data)
    s3_client = Aws::S3::Client.new(region: "us-east-1", credentials: s3_credentials)
    current_time = Time.current
    timestamp_string = current_time.strftime("%Y%m%d-%H%M%S")


    s3_client.put_object(
      bucket: destination_bucket,
      key: "#{Rails.env}-intakes-to-submission-pdf-key-#{timestamp_string}.json",
      body: JSON.generate(hash_data)
    )
  end

  def s3_credentials
    if ENV["AWS_ACCESS_KEY_ID"].present? # is this for local?
      Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
    else
      Aws::Credentials.new(
        Rails.application.credentials.dig(:aws, :access_key_id),
        Rails.application.credentials.dig(:aws, :secret_access_key)
      )
    end
  end
end

CopyToNewS3Bucket.start