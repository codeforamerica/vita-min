# frozen_string_literal: true

class RemoveDocumentTypeSelfie < ActiveRecord::Migration[7.1]
  def up
    selfie_documents = Document.where(document_type: "Selfie")

    puts "There are #{selfie_documents.count} selfies in the database"

    selfie_documents.in_batches do |relation|
      relation.delete_all
      sleep(10) # Throttle the delete queries
    end

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
