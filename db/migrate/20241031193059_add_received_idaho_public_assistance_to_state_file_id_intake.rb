class AddReceivedIdahoPublicAssistanceToStateFileIdIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id_intakes, :received_id_public_assistance, :integer, default: 0, null: false
  end
end
