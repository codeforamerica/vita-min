class AddClientToIntake < ActiveRecord::Migration[6.0]
  def change
    add_reference :intakes, :client
  end
end
