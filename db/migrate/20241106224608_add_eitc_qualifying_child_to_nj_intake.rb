class AddEitcQualifyingChildToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :claimed_as_eitc_qualifying_child, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :spouse_claimed_as_eitc_qualifying_child, :integer, default: 0, null: false
  end
end
