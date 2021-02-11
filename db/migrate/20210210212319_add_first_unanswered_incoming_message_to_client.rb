class AddFirstUnansweredIncomingMessageToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :first_unanswered_incoming_correspondence_at, :datetime
  end
end
