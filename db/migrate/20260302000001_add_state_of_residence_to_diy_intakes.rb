class AddStateOfResidenceToDiyIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :diy_intakes, :state_of_residence, :string
  end
end
