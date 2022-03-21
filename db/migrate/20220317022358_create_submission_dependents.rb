class CreateSubmissionDependents < ActiveRecord::Migration[6.1]
  def change
    create_table :efile_submission_dependents do |t|
      t.references :efile_submission
      t.references :dependent
      t.boolean :qualifying_child
      t.boolean :qualifying_relative
      t.boolean :qualifying_ctc
      t.integer :age_during_tax_year
      t.timestamps
    end
  end
end
