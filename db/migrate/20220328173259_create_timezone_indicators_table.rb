class CreateTimezoneIndicatorsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :timezone_indicators do |t|
      t.boolean :override, default: true
      t.string :name
      t.timestamp :activated_at
      t.timestamps
    end
  end
end
