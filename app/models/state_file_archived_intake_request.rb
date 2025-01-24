# == Schema Information
#
# Table name: state_file_archived_intake_requests
#
#  id                            :bigint           not null, primary key
#  email_address                 :string
#  failed_attempts               :integer          default(0), not null
#  fake_address_1                :string
#  fake_address_2                :string
#  ip_address                    :string
#  locked_at                     :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  state_file_archived_intake_id :bigint
#
# Indexes
#
#  idx_on_state_file_archived_intake_id_7dd0f99380  (state_file_archived_intake_id)
#
require 'csv'

class StateFileArchivedIntakeRequest < ApplicationRecord
  devise :lockable, unlock_in: 60.minutes, unlock_strategy: :time
  has_many :state_file_archived_intake_access_logs, class_name: 'StateFileArchivedIntakeAccessLog'
  belongs_to :state_file_archived_intake, class_name: 'StateFileArchivedIntake', optional: true

  before_create :populate_fake_addresses

  def self.maximum_attempts
    2
  end

  def increment_failed_attempts
    super
    lock_access! if attempts_exceeded? && !access_locked?
  end

  def fake_addresses
    [fake_address_1, fake_address_2]
  end

  private

  def populate_fake_addresses
    self.fake_address_1, self.fake_address_2 = fetch_random_addresses
  end

  def fetch_random_addresses
    if state_file_archived_intake.present?
      if Rails.env.development? || Rails.env.test?
        file_path = Rails.root.join('app', 'lib', 'challenge_addresses', 'test_addresses.csv')
      else
        bucket = select_bucket

        file_key = Rails.env.production? ? "#{state_file_archived_intake.mailing_state.downcase}_addresses.csv" : 'non_prod_addresses.csv'

        file_path = File.join(Rails.root, "tmp", File.basename(file_key))

        download_file_from_s3(bucket, file_key, file_path) unless File.exist?(file_path)
      end
      addresses = CSV.read(file_path, headers: false).flatten
      addresses.sample(2)
    end
  end

  def download_file_from_s3(bucket, file_key, file_path)
    s3_client = Aws::S3::Client.new(region: 'us-east-1', credentials: s3_credentials)
    s3_client.get_object(
      response_target: file_path,
      bucket: bucket,
      key: file_key
    )
  end

  def s3_credentials
    if ENV["AWS_ACCESS_KEY_ID"].present?
      Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
    else
      Aws::Credentials.new(
        Rails.application.credentials.dig(:aws, :access_key_id),
        Rails.application.credentials.dig(:aws, :secret_access_key)
      )
    end
  end

  def select_bucket
    case Rails.env
    when 'production'
      'vita-min-prod-docs'
    when 'staging'
      'vita-min-staging-docs'
    when 'demo'
      'vita-min-demo-docs'
    when 'heroku'
      'vita-min-heroku-docs'
    end
  end
end