class RefactorDiyIntake < ActiveRecord::Migration[6.0]
  def change
    remove_column :diy_intakes, :preferred_name, :string
    remove_column :diy_intakes, :state_of_residence, :string
    remove_column :diy_intakes, :token, :string
    remove_column :diy_intakes, :requester_id, :bigint
    remove_column :diy_intakes, :ticket_id, :bigint
    add_column :diy_intakes, :zip_code, :string
  end
end
