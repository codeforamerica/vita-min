# frozen_string_literal: true

class ArchiveHadStudentInFamilyColumn < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      execute <<~SQL
        INSERT INTO intake_archives(id, had_student_in_family)
          (SELECT id, had_student_in_family from intakes)
        ON CONFLICT (id) DO
          UPDATE SET had_student_in_family=EXCLUDED.had_student_in_family
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
