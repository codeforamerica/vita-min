class AddRoutingMethodToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :routing_method, :integer
  end
end
