class CreateAnonymizedDiyIntakeCsvExtracts < ActiveRecord::Migration[6.0]
  def change
    create_table :anonymized_diy_intake_csv_extracts do |t|
      t.datetime :run_at
      t.integer :record_count

      t.timestamps
    end
  end
end
