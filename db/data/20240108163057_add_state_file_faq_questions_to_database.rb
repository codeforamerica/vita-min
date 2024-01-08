# frozen_string_literal: true

class AddStateFileFaqQuestionsToDatabase < ActiveRecord::Migration[7.1]
  def up
    StateFile::FaqDatabaseExportService.export_yml_to_database
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
