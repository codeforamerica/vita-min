class AddPhotoIdTypesToCtcIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :with_drivers_license_photo_id, :boolean, default: false
    add_column :intakes, :with_passport_photo_id, :boolean, default: false
    add_column :intakes, :with_other_state_photo_id, :boolean, default: false
    add_column :intakes, :with_vita_approved_photo_id, :boolean, default: false
  end
end
