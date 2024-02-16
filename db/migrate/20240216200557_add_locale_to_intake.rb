class AddLocaleToIntake < ActiveRecord::Migration[7.1]
  def up
    add_column :state_file_az_intakes, :locale, :string, default: 'us'
    add_column :state_file_ny_intakes, :locale, :string, default: 'us'
  end

  def down
    remove_column :state_file_az_intakes, :locale
    remove_column :state_file_ny_intakes, :locale
  end
end
