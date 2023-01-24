class RemoveArchivedIntakeColumns < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :intakes, :needs_help_2017, :integer, default: 0, null: false
      remove_column :intakes, :was_on_visa, :integer, default: 0, null: false
      remove_column :intakes, :spouse_was_on_visa, :integer, default: 0, null: false
    end
  end
end
