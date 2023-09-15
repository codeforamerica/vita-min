# frozen_string_literal: true

class BackfillHashedDependentSsn < ActiveRecord::Migration[7.0]
  def up
    dependents_left_to_backfill = Dependent.where(hashed_ssn: nil).where.not(ssn: nil)
    dependents_left_to_backfill.find_in_batches do |batch|
      Dependent.upsert_all(
        batch.map { |dependent|
          { id: dependent.id, hashed_ssn: DeduplicationService.sensitive_attribute_hashed(dependent, :ssn), birth_date: dependent.birth_date, intake_id: dependent.intake.id }
        },
        update_only: [:hashed_ssn]
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
