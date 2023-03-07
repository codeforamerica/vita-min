# frozen_string_literal: true

class ChangeF13614cDocumentTypeOnDocuments < ActiveRecord::Migration[7.0]
  def up
    Document.where(document_type: "F13614C 2020").in_batches(of: 10_000) do |doc_batch|
      doc_batch.update_all(document_type: "F13614C")
    end
  end

  def down
    Document.where(document_type: "F13614C").in_batches(of: 10_000) do |doc_batch|
      doc_batch.update_all(document_type: "F13614C 2020")
    end
  end
end
