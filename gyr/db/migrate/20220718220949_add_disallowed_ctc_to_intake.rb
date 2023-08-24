class AddDisallowedCtcToIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :disallowed_ctc, :boolean
  end
end
