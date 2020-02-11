class AddConsentFieldsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :consented_to_service, :integer, default: 0, null: false
    add_column :users, :consented_to_service_ip, :string
    add_column :users, :consented_to_service_at, :datetime
  end
end
