class CreateEfileSecurityInformations < ActiveRecord::Migration[6.0]
  def change
    create_table :efile_security_informations do |t|
      t.inet :ip_address
      t.string :device_id
      t.string :user_agent
      t.string :language
      t.string :platform
      t.string :timezone_offset
      t.string :client_system_time
      t.timestamps
    end
  end
end
