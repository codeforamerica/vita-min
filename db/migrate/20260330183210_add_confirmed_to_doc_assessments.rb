class AddConfirmedToDocAssessments < ActiveRecord::Migration[7.1]
  def change
    add_column :doc_assessments, :confirmed, :boolean
  end
end
