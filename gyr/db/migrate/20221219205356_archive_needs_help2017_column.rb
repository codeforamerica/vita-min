class ArchiveNeedsHelp2017Column < ActiveRecord::Migration[7.0]
  def change
    add_column :intake_archives, :needs_help_2017, :integer
    reversible do |direction|
      direction.up do
        safety_assured do
          # Safe for migrations because this is an INSERT into a column we are creating in this transactional migration.
          execute <<~SQL
            INSERT INTO intake_archives(id, needs_help_2017)
              (SELECT id, needs_help_2017 from intakes)
            ON CONFLICT (id) DO
              UPDATE SET needs_help_2017=EXCLUDED.needs_help_2017
          SQL
        end
      end
    end
  end
end
