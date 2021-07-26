class FlipCanBeClaimedByOtherOnDependent < ActiveRecord::Migration[6.0]
  def change
    rename_column :dependents, :can_be_claimed_by_other, :cant_be_claimed_by_other
  end
end
