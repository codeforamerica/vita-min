# == Schema Information
#
# Table name: system_notes
#
#  id         :bigint           not null, primary key
#  body       :text
#  data       :jsonb
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#  user_id    :bigint
#
# Indexes
#
#  index_system_notes_on_client_id  (client_id)
#  index_system_notes_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
class SystemNote::AssignmentChange < SystemNote
  def self.generate!(initiated_by: user, tax_return:)
    return unless tax_return.saved_change_to_assigned_user_id? # if the assigned user didn't change, don't persist

    action = if tax_return.assigned_user.present?
               "assigned #{tax_return.year} return to #{tax_return.assigned_user.name_with_role}."
             else
               "removed assignment from #{tax_return.year} return."
             end

    create!(
      user: initiated_by,
      client: tax_return.client,
      body: "#{initiated_by.name_with_role} #{action}"
    )
  end
end
