class RenameCasesToCaseFiles < ActiveRecord::Migration[6.0]
  def change
    rename_table :cases, :case_files
  end
end