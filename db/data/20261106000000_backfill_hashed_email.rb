# frozen_string_literal: true

class BackfillHashedEmail < ActiveRecord::Migration[8.1]
  def up
    Intake.where(hashed_email: nil).where.not(email_address: [nil, ""]).find_each(batch_size: 1000) do |intake|
      intake.update_column(:hashed_email, EmailHashingService.hash(intake.email_address))
    end

    [
      StateFileAzIntake,
      StateFileIdIntake,
      StateFileMdIntake,
      StateFileNcIntake,
      StateFileNjIntake,
      StateFileNyIntake,
      StateFileArchivedIntake
    ].each do |klass|
      klass.where(hashed_email: nil).where.not(email_address: [nil, ""]).find_each(batch_size: 1000) do |intake|
        intake.update_column(:hashed_email, EmailHashingService.hash(intake.email_address))
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
