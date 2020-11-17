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

  # If we ever need to add statuses between these numbers, we can multiply these by 100, do a data migration, and
  # then insert a value in between.
  #
  # The first word of each status name is treated as a "stage" when grouping these in the interface.
  STATUSES = {
      intake_before_consent: 100, intake_in_progress: 101, intake_open: 102, intake_review: 103, intake_more_info: 104, intake_info_requested: 105, intake_needs_assignment: 106,
      prep_ready_for_call: 201, prep_more_info: 202, prep_preparing: 203, prep_ready_for_review: 204,
      review_in_review: 301, review_complete_signature_requested: 302, review_more_info: 303,
      finalize_closed: 401, finalize_signed: 402,
      filed_e_file: 501, filed_mail_file: 502, filed_rejected: 503, filed_accepted: 504
  }

  enum status: STATUSES, _prefix: :status

  ##
  # advance the return to a new status, only if that status more advanced.
  # An earlier or equal status will be ignored.
  #
  # @param [String] new_status: the name of the status to advance to
  #
  def advance_to(new_status)
    update!(status: new_status) if TaxReturn::STATUSES[status.to_sym] < TaxReturn::STATUSES[new_status.to_sym]
  end
end