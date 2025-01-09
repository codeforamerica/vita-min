# == Schema Information
#
# Table name: state_file_archived_intake_requests
#
#  id                             :bigint           not null, primary key
#  details                        :jsonb
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
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :lockable, :timeoutable, :trackable

  has_many :access_logs, class_name: 'StateFileArchivedIntakeAccessLog'
end
