class AddFinalInfoToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :final_info, :string
  end
end
