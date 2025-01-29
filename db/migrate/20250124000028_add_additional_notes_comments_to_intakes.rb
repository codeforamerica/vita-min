class AddAdditionalNotesCommentsToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :additional_notes_comments, :text
  end
end
