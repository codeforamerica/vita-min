class IndexAllIntakeRecords < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  class Intake < ActiveRecord::Base; end

  def up
    Intake.unscoped.in_batches do |relation|
      relation.update_all needs_to_flush_searchable_data_set_at: Time.current
      sleep(0.01) # throttle
    end
  end
end
