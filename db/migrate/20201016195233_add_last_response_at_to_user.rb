class AddLastResponseAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :last_response_at, :datetime
  end
end
