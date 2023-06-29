# frozen_string_literal: true

class AddFaqQuestionsToDatabase < ActiveRecord::Migration[7.0]
  def up
    FaqDatabaseExportService.export_yml_to_database
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
