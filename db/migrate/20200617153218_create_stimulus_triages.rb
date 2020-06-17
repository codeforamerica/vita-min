class CreateStimulusTriages < ActiveRecord::Migration[6.0]
  def change
    create_table :stimulus_triages do |t|
      t.integer :filed_recently, default: 0, null: false
      t.integer :need_to_correct, default: 0, null: false
      t.integer :filed_prior_years, default: 0, null: false
      t.integer :need_to_file, default: 0, null: false
      t.integer :chose_to_file, default: 0, null: false

      t.timestamps
    end
  end
end
