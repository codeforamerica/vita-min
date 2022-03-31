class CreateTimezoneIndicatorsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :fraud_indicators_timezones do |t|
      t.string :name
      t.timestamp :activated_at
      t.timestamps
    end
  end
end
