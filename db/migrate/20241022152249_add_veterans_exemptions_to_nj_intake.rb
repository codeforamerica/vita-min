class AddVeteransExemptionsToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :spouse_veteran, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :primary_veteran, :integer, default: 0, null: false
  end
end