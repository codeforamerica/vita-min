class AddThirdPartyDesigneeFieldsToStateFileNyIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_ny_intakes, :confirm_third_party_designee, :integer, default: 0, null: false
  end
end
