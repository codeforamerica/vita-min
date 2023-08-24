class AddMoreColumnsToAbandonedIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :abandoned_pre_consent_intakes, :triage_filing_frequency, :integer
    add_column :abandoned_pre_consent_intakes, :triage_filing_status, :integer
    add_column :abandoned_pre_consent_intakes, :triage_income_level, :integer
    add_column :abandoned_pre_consent_intakes, :triage_vita_income_ineligible, :integer
    add_column :abandoned_pre_consent_intakes, :referrer, :string
    add_column :abandoned_pre_consent_intakes, :intake_type, :string
    add_column :abandoned_pre_consent_intakes, :visitor_id, :string
  end
end
