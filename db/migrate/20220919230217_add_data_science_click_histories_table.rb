class AddDataScienceClickHistoriesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :ds_click_histories do |t|
      t.timestamps
      t.references :client, null: false, foreign_key: true, dependent: :destroy,  index: {unique: true}
      t.timestamp :w2_logout_add_later
    end
  end
end
