class CreateAccessLog < ActiveRecord::Migration[6.0]
  def change
    create_table :access_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.string :user_agent, null: false
      t.inet :ip_address
      t.timestamps
    end
  end
end
