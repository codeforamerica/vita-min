class AddUnsubscribedFromEmailToStateFileNcIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :unsubscribed_from_email, :boolean, null: false, default: false
  end
end
