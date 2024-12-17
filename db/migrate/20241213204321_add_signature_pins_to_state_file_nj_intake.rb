class AddSignaturePinsToStateFileNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :primary_signature_pin, :text
    add_column :state_file_nj_intakes, :spouse_signature_pin, :text
  end
end
