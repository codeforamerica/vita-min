# frozen_string_literal: true

class ArchiveOnVisaColumns < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      execute <<~SQL
        INSERT INTO intake_archives(id, was_on_visa, spouse_was_on_visa)
          (SELECT id, was_on_visa, spouse_was_on_visa from intakes)
        ON CONFLICT (id) DO
          UPDATE SET was_on_visa=EXCLUDED.was_on_visa, spouse_was_on_visa=EXCLUDED.spouse_was_on_visa
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
