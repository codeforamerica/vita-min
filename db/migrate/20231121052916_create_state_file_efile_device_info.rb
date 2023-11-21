class CreateStateFileEfileDeviceInfo < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file_efile_device_infos do |t|
      t.integer :device_type, default: 0, null: false
      t.inet :ip_address
      t.string :user_agent
      t.string :device_id
      t.string :event_type
      t.references :intake, polymorphic: true, null: false
      t.timestamps
    end
  end
end
