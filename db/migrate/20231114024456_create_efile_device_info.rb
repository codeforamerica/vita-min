class CreateEfileDeviceInfo < ActiveRecord::Migration[7.1]
  def change
    create_table :efile_device_infos do |t|
      t.timestamps
      t.integer :device_type, default: 0, null: false
      t.string :ip_address
      t.string :device_id
      t.string :ip_port_num
      t.string :ipts
      t.references :intake, polymorphic: true, null: false
    end
  end
end