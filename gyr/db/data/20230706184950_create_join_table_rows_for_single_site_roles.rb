# frozen_string_literal: true

class CreateJoinTableRowsForSingleSiteRoles < ActiveRecord::Migration[7.0]
  def up
    # content obsolete -- migration has successfully run on all environments
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
