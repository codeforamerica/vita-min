class AddLastRespondedAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :last_response_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
