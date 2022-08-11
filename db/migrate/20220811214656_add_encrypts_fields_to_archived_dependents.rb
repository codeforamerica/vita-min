class AddEncryptsFieldsToArchivedDependents < ActiveRecord::Migration[7.0]
  def change
    add_column :archived_dependents_2021, :ip_pin, :text
    add_column :archived_dependents_2021, :ssn, :text
  end
end
