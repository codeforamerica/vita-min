class AddSpouseDeathYearToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :spouse_death_year, :integer, null: true
  end
end
