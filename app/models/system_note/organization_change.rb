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
class SystemNote::OrganizationChange < SystemNote
  def self.generate!(client:, initiated_by: nil)
    return unless client.saved_change_to_vita_partner_id? # if the assigned user didn't change, don't continue

    previous_partner = VitaPartner.find_by(id: client.vita_partner_id_previous_change[0])
    current_partner = client.vita_partner

    action = if previous_partner.present? && current_partner.present?
               "changed assigned partner from #{previous_partner.name} to #{current_partner.name}."
             elsif current_partner.present? # nil -> assigned
               "assigned client to #{current_partner.name}."
             else # assigned -> nil
               "removed partner assignment from client. (Previously assigned to #{previous_partner.name}.)"
             end

    body = initiated_by ? "#{initiated_by.name} #{action}" : "A system action #{action}"

    create!(
      user: initiated_by,
      client: client,
      body: body
    )
  end
end
