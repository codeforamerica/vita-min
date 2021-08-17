class UseSpouseNameForControl < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :use_spouse_name_for_name_control, :boolean
  end
end
