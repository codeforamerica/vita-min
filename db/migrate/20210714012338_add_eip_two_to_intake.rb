class AddEipTwoToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :eip_two, :integer
  end
end
