# == Schema Information
#
# Table name: system_notes
#
#  id         :bigint           not null, primary key
#  body       :text
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
class SystemNote::SignedDocument < SystemNote
  def self.generate!(tax_return:, signed_by_type:, waiting: false)
    accepted_types = [:spouse, :primary]
    raise ArgumentError, "Invalid signed by type" unless accepted_types.include? signed_by_type.to_sym

    signed_by_type = signed_by_type.to_sym

    title_map = {
        spouse: "spouse of taxpayer",
        primary: "primary taxpayer"
    }

    body = "#{title_map[signed_by_type].capitalize} signed #{tax_return.year} form 8879."
    if waiting
      waiting_for_type = (accepted_types - [signed_by_type]).first
      body << " Waiting on #{title_map[waiting_for_type]} to sign."
    end

    create!(
      body: body,
      client: tax_return.client,
    )
  end
end
