class AddSignaturePinsToStateFileMdIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :primary_signature_pin, :text
    add_column :state_file_md_intakes, :spouse_signature_pin, :text
  end
end
