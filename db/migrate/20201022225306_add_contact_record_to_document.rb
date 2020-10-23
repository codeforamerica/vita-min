class AddContactRecordToDocument < ActiveRecord::Migration[6.0]
  def change
    add_reference :documents, :contact_record, polymorphic: true, null: true
  end
end
