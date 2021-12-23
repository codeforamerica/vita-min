class AddNew2022IntakeAttributes < ActiveRecord::Migration[6.1]
  def change
    add_column :intakes, :eip3_amount_received, :integer
    add_column :intakes, :advance_ctc_amount_received, :integer
    add_column :intakes, :preferred_written_language, :string
    add_column :intakes, :received_advance_ctc_payment, :integer
  end
end
