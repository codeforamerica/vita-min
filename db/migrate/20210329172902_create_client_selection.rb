class CreateClientSelection < ActiveRecord::Migration[6.0]
  def change
    create_table :client_selections do |t|
      t.timestamps
    end
  end
end
