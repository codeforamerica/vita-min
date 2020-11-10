# == Schema Information
#
# Table name: tax_returns
#
#  id               :bigint           not null, primary key
#  status           :integer          default("intake_before_consent"), not null
#  year             :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  assigned_user_id :bigint
#  client_id        :bigint           not null
#
# Indexes
#
#  index_tax_returns_on_assigned_user_id    (assigned_user_id)
#  index_tax_returns_on_client_id           (client_id)
#  index_tax_returns_on_year_and_client_id  (year,client_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (assigned_user_id => users.id)
#  fk_rails_...  (client_id => clients.id)
#
class TaxReturn < ApplicationRecord
  belongs_to :client
  belongs_to :assigned_user, class_name: "User", optional: true

  INTAKE = "intake".freeze
  PREP = "prep".freeze
  REVIEW = "review".freeze
  FINALIZE = "finalize".freeze
  FILED = "filed".freeze

  STAGES = [INTAKE, PREP, REVIEW, FINALIZE, FILED].freeze

  # If we ever need to add statuses between these numbers, we can multiply these by 100, do a data migration, and
  # then insert a value in between.
  enum status: {
    intake_before_consent: 100, intake_in_progress: 101, intake_open: 102, intake_review: 103, intake_more_info: 104, intake_info_requested: 105, intake_needs_assignment: 106,
    prep_ready_for_call: 201, prep_more_info: 202, prep_preparing: 203, prep_ready_for_review: 204,
    review_in_review: 301, review_complete_signature_requested: 302, review_more_info: 303,
    finalize_closed: 401, finalize_signed: 402,
    filed_e_file: 501, filed_mail_file: 502, filed_rejected: 503, filed_accepted: 504
  }, _prefix: :status

  def self.statuses_for(stage)
    statuses_by_stage[stage]
  end

  def self.statuses_by_stage
    statuses.group_by { |key, _| key.split("_")[0] }
  end

  def stage
    return nil unless status.present?

    TaxReturn::STAGES.find { |stage| status.starts_with?(stage) }
  end
end
