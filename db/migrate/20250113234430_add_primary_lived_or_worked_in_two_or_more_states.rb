class AddPrimaryLivedOrWorkedInTwoOrMoreStates < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :primary_lived_or_worked_in_two_or_more_states, :integer, default: 0, null: false
  end
end
