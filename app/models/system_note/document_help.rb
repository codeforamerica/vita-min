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
class SystemNote::DocumentHelp < SystemNote
  HELP_TYPES = [
    :doesnt_apply,
    :cant_locate,
    :cant_obtain
  ].freeze

  def self.generate!(client:, help_type:, doc_type:)
    raise ArgumentError, "Invalid help_type" unless HELP_TYPES.include?(help_type.to_sym)
    raise ArgumentError, "Invalid doc_type" unless DocumentTypes::ALL_TYPES.include?(doc_type)

    create!(
      client: client,
      data: {
        help_type: help_type,
        doc_type: doc_type.name
      }
    )
  end

  def help_type
    data["help_type"]
  end

  def doc_type
    data["doc_type"].constantize
  end
end
