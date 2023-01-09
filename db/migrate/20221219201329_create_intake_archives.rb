class CreateIntakeArchives < ActiveRecord::Migration[7.0]
  def change
    create_table :intake_archives do |t|
      # t.integer :needs_help_2017
    end

    # Adding a foreign key blocks writes on both tables. There are not many writes on these tables during December 2022.
    safety_assured {
      add_foreign_key :intake_archives, :intakes, column: :id, primary_key: :id
    }
  end
end
