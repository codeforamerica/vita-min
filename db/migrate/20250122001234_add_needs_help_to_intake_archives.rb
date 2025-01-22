class AddNeedsHelpToIntakeArchives < ActiveRecord::Migration[7.1]
  def change
    add_column :intake_archives, :needs_help_2018, :integer
    # add_column :intake_archives, :needs_help_2019, :integer
    # add_column :intake_archives, :needs_help_2020, :integer
    reversible do |direction|
      direction.up do
        safety_assured do
          # Safe for migrations because this is an INSERT into a column we are creating in this transactional migration.
          execute <<~SQL
            INSERT INTO intake_archives(id, needs_help_2018)
              (SELECT id, needs_help_2018 from intakes)
            ON CONFLICT (id) DO
              UPDATE SET needs_help_2018=EXCLUDED.needs_help_2018
          SQL
        end
      end
    end
  end
end
