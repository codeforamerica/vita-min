class CreateReports < ActiveRecord::Migration[6.0]
  def change
    create_table :reports do |t|
      t.string :type
      t.jsonb :data
      t.datetime :generated_at
      t.index :generated_at
      t.timestamps
    end
  end
end
