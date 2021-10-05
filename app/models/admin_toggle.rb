# == Schema Information
#
# Table name: admin_toggles
#
#  id         :bigint           not null, primary key
#  name       :string
#  value      :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_admin_toggles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class AdminToggle < ApplicationRecord
  FORWARD_MESSAGES_TO_INTERCOM = 'forward_messages_to_intercom'.freeze

  BOOLEAN_FLAGS = [FORWARD_MESSAGES_TO_INTERCOM].freeze

  belongs_to :user

  def self.current_value_for(name, default: nil)
    last_toggle = where(name: name).order('created_at DESC').first
    return default unless last_toggle

    last_toggle.value
  end
end
