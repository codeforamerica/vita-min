class DropCtcStandaloneTables < ActiveRecord::Migration[8.1]
  def up
    drop_table :ctc_signups, if_exists: true
    drop_table :archived_bank_accounts_2021, if_exists: true
    drop_table :archived_dependents_2021, if_exists: true
    drop_table :archived_intakes_2021, if_exists: true
  end

  def down
    # prevents someone from accidentally running rails db:rollback and expecting the tables to come back
    raise ActiveRecord::IrreversibleMigration
  end
end
