class ChangeNameFieldsOnIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :primary_first_name, :string
    add_column :intakes, :spouse_first_name, :string
    add_column :intakes, :primary_last_name, :string
    add_column :intakes, :spouse_last_name, :string

    remove_column :intakes, :primary_full_legal_name, :string
    remove_column :intakes, :spouse_full_legal_name, :string
  end
end
