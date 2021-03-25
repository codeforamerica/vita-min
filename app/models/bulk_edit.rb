# == Schema Information
#
# Table name: bulk_edits
#
#  id         :bigint           not null, primary key
#  data       :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class BulkEdit < ApplicationRecord
  delegate :hub_clients_path, to: 'Rails.application.routes.url_helpers'

  def self.generate!(user:, record_type:, successful_ids: [], failed_ids: [])
    raise UnsupportedRecordType unless [Client, TaxReturn].include?(record_type)

    record = create!(data: {
      record_type: record_type.to_s,
      successful_ids: successful_ids,
      failed_ids: failed_ids
    })

    UserNotification.create(
      user: user,
      notifiable: record
    )
    record
  end

  def successful_ids
    @successful_ids ||= data["successful_ids"]
  end

  def failed_ids
    @failed_ids ||= data["failed_ids"]
  end

  def record_type
    @record_type ||= data["record_type"].constantize
  end

  def records_path(failed: nil, successful: nil)
    params = { bulk_edit: id }
    params['only'] = 'failed' if failed && !successful
    params['only'] = 'successful' if successful && !failed
    hub_clients_path(params)
  end

  class UnsupportedRecordType < StandardError; end
end
