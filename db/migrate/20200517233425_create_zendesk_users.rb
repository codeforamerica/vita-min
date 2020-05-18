class CreateZendeskUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.bigint :zendesk_user_id
      t.string :name
      t.string :email
      t.string :role
      t.bigint :organization_id
      t.string :ticket_restriction
      t.boolean :two_factor_auth_enabled
      t.boolean :active
      t.boolean :suspended
      t.boolean :verified
      t.timestamps
    end
  end
end
