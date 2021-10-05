class CreateRecaptchaScores < ActiveRecord::Migration[6.0]
  def change
    create_table :recaptcha_scores do |t|
      t.decimal :score, null: false
      t.string :action, null: false
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
