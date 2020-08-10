class AddEipOnlyToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :eip_only, :boolean
  end
end
