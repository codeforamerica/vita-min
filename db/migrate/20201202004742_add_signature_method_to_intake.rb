class AddSignatureMethodToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :signature_method, :integer, default: 0, null: false
  end
end
