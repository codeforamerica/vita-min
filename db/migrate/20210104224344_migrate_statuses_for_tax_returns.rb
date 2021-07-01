class MigrateStatusesForTaxReturns < ActiveRecord::Migration[6.0]
  def up
    MigrateStatuses.migrate_all
  end

  def down
    # noop
  end
end
