class AddUnsubscribedFromEmailToStateFileIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :unsubscribed_from_email, :boolean, null: false, default: false
    add_column :state_file_ny_intakes, :unsubscribed_from_email, :boolean, null: false, default: false
  end
end
