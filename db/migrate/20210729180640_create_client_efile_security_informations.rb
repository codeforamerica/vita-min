class CreateClientEfileSecurityInformations < ActiveRecord::Migration[6.0]
  def change
    create_table :client_efile_security_informations do |t|
      t.string :device_id, null: false
      t.string :user_agent, null: false
      t.string :browser_language, null: false
      t.string :platform, null: false
      t.string :timezone_offset, null: false
      t.string :client_system_time, null: false
      t.belongs_to :client, index: true, foreign_key: true, null: false
      t.timestamps
    end
  end
end
