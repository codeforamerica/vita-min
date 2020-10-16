class RemoveClientFromDocument < ActiveRecord::Migration[6.0]
  def change
    remove_reference :documents, :client
  end
end
