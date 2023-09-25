# frozen_string_literal: true

class BackfillHashedSpouseSsn < ActiveRecord::Migration[7.0]
  def up
    intakes_left_to_backfill =Intake.where(hashed_spouse_ssn: nil).where.not(spouse_ssn: nil)

    intakes_left_to_backfill.find_in_batches do |batch|
      Intake.upsert_all(
        batch.map { |intake|
          { id: intake.id, hashed_spouse_ssn: DeduplicationService.sensitive_attribute_hashed(intake, :spouse_ssn) }
        },
        update_only: [:hashed_spouse_ssn]
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
