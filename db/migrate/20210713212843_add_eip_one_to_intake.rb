class AddEipOneToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :eip_one, :integer
  end
end
