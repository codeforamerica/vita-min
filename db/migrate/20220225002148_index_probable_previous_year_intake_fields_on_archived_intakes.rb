class IndexProbablePreviousYearIntakeFieldsOnArchivedIntakes < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :archived_intakes_2021, [:primary_birth_date, :primary_first_name, :primary_last_name], name: "index_arcint_2021_on_probable_previous_year_intake_fields", algorithm: :concurrently
  end
end
