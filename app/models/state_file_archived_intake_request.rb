# == Schema Information
#
# Table name: state_file_archived_intake_requests
#
#  id                             :bigint           not null, primary key
#  email_address                  :string
#  failed_attempts                :integer          default(0), not null
#  ip_address                     :string
#  locked_at                      :datetime
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  state_file_archived_intakes_id :bigint
#
# Indexes
#
#  idx_on_state_file_archived_intakes_id_31501c23f8  (state_file_archived_intakes_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_file_archived_intakes_id => state_file_archived_intakes.id)
#
class StateFileArchivedIntakeRequest < ApplicationRecord
  devise :lockable, unlock_in: 60.minutes, unlock_strategy: :time
  has_many :access_logs, class_name: 'StateFileArchivedIntakeAccessLog'
  belongs_to :state_file_archived_intake, class_name: 'StateFileArchivedIntake'

  def self.maximum_attempts
    2
  end

  def increment_failed_attempts
    super
    if attempts_exceeded? && !access_locked?
      lock_access!
    end
  end
end
