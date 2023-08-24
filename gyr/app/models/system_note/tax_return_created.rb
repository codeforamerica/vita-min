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
class SystemNote::TaxReturnCreated < SystemNote
  def self.generate!(tax_return:, initiated_by:)
    user_info = initiated_by.role_name
    body = "#{initiated_by.name_with_role_and_entity} added a #{tax_return.year} tax return."

    create!(
      body: body,
      client: tax_return.client,
      user: initiated_by
    )
  end
end
