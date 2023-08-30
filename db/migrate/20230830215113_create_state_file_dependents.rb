class CreateStateFileDependents < ActiveRecord::Migration[7.0]
  def change
    create_table :state_file_dependents do |t|
      t.string :first_name
      t.string :middle_initial
      t.string :last_name
      t.date :dob
      t.string :ssn
      t.string :relationship
      t.string :suffix
      t.references :intake, polymorphic: true, null: false

      t.timestamps
    end
  end
end
