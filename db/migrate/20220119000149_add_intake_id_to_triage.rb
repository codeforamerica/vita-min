class AddIntakeIdToTriage < ActiveRecord::Migration[6.1]
  def change
    add_reference :triages, :intake
  end
end