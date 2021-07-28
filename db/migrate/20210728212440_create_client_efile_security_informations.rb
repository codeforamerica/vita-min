class CreateClientEfileSecurityInformations < ActiveRecord::Migration[6.0]
  def change
    create_table :client_efile_security_informations do |t|
      t.inet :ip_address
      t.string :device_id
      t.string :user_agent
      t.string :language
      t.string :platform
      t.string :timezone_offset
      t.string :client_system_time
      t.belongs_to :client, index: true, foreign_key: true
      t.timestamps
    end
  end
end
