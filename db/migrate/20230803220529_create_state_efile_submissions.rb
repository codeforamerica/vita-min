class CreateStateEfileSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :state_efile_submissions do |t|
      t.string :irs_submission_id
      t.datetime :last_checked_for_ack_at
      t.references :intake, polymorphic: true, null: false

      t.timestamps
    end
  end
end
