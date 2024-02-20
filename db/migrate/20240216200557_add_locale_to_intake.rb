class AddLocaleToIntake < ActiveRecord::Migration[7.1]
  def up
    add_column :state_file_az_intakes, :locale, :string, default: 'en'
    add_column :state_file_ny_intakes, :locale, :string, default: 'en'
  end

  def down
    remove_column :state_file_az_intakes, :locale
    remove_column :state_file_ny_intakes, :locale
  end
end
