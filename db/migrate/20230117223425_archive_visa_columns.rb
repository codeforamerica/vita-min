class ArchiveVisaColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :intake_archives, :was_on_visa, :integer
    add_column :intake_archives, :spouse_was_on_visa, :integer

    reversible do |direction|
      direction.up do
        safety_assured do
          # Safe for migrations because this is an INSERT into a column we are creating in this transactional migration.
          execute <<~SQL
            INSERT INTO intake_archives(id, was_on_visa)
              (SELECT id, was_on_visa from intakes)
            ON CONFLICT (id) DO
              UPDATE SET was_on_visa=EXCLUDED.was_on_visa
          SQL
        end
      end
    end

    reversible do |direction|
      direction.up do
        safety_assured do
          # Safe for migrations because this is an INSERT into a column we are creating in this transactional migration.
          execute <<~SQL
            INSERT INTO intake_archives(id, spouse_was_on_visa)
              (SELECT id, spouse_was_on_visa from intakes)
            ON CONFLICT (id) DO
              UPDATE SET spouse_was_on_visa=EXCLUDED.spouse_was_on_visa
          SQL
        end
      end
    end
  end
end
