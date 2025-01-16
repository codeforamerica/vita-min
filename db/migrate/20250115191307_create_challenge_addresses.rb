class CreateChallengeAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :challenge_addresses do |t|
      t.string :address, null: false
      t.string :state_code, null: false

      t.timestamps
    end
  end
end
