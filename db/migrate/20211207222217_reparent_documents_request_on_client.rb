class ReparentDocumentsRequestOnClient < ActiveRecord::Migration[6.1]
  def up
    add_reference :documents_requests, :client, foreign_key: true, index: true
    execute("UPDATE documents_requests SET client_id = intakes.client_id FROM intakes WHERE documents_requests.intake_id = intakes.id")
    remove_reference :documents_requests, :intake
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
