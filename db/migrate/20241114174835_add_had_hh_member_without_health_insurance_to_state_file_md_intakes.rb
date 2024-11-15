class AddHadHhMemberWithoutHealthInsuranceToStateFileMdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :had_hh_member_without_health_insurance, :integer, null: false, default: 0
  end
end
