# == Schema Information
#
# Table name: client_interactions
#
#  id               :bigint           not null, primary key
#  interaction_type :integer          default("unfilled"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  client_id        :bigint           not null
#
# Indexes
#
#  index_client_interactions_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
class ClientInteraction < ApplicationRecord
  belongs_to :client
  enum interaction_type: { unfilled: 0, document_upload: 1, client_message: 2 }, _prefix: :interaction_type

  def mail_method
    case interaction_type
    when 'document_upload'
      # TODO: :document_uploaded_notification_email
    when 'client_message'
      :incoming_interaction_notification_email
    end
  end
end
