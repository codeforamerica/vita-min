class AddTriageColumnsToIntake < ActiveRecord::Migration[6.1]
  def change
    add_column :intakes, :triage_income_level, :integer, default: 0, null: false
    add_column :intakes, :triage_filing_status, :integer, default: 0, null: false
    add_column :intakes, :triage_filing_frequency, :integer, default: 0, null: false
    add_column :intakes, :triage_vita_income_ineligible, :integer, default: 0, null: false
  end
end
