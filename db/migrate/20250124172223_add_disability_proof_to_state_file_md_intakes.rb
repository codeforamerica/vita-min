class AddDisabilityProofToStateFileMdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :proof_of_disability_submitted, :integer, default: 0, null: false
  end
end
