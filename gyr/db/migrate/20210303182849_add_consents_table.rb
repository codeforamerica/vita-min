class AddConsentsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :consents do |t|
      t.references :client, null: false, index: true

      t.datetime :use_consented_at
      t.datetime :disclose_consented_at
      t.datetime :relational_efin_consented_at
      t.datetime :global_carryforward_consented_at
      t.inet :ip
      t.string :user_agent
      t.timestamps
    end
  end
end
