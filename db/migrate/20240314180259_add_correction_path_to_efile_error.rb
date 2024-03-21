class AddCorrectionPathToEfileError < ActiveRecord::Migration[7.1]
  def change
    add_column :efile_errors, :correction_path, :string
  end
end
