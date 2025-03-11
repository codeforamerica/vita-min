class SeparateColumnsForProofOfDisabled < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :state_file_md_intakes, :proof_of_disability_submitted, :integer, default: 0, null: false
    end
    add_column :state_file_md_intakes, :primary_proof_of_disability_submitted, :integer, default: 0, null: false
    add_column :state_file_md_intakes, :spouse_proof_of_disability_submitted, :integer, default: 0, null: false
  end
end
