class RemoveSsbAmountsFromStateFileMdIntake < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :state_file_md_intakes, :primary_ssb_amount
      remove_column :state_file_md_intakes, :spouse_ssb_amount
    end
  end
end
