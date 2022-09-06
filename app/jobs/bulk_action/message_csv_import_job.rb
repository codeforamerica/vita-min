require 'csv'

module BulkAction
  class MessageCsvImportJob < ApplicationJob
    def perform(bulk_message_csv)
      csv_content = bulk_message_csv.upload.download
      io = StringIO.new(csv_content)
      io.set_encoding_by_bom
      client_ids = CSV.parse(io, headers: true).map { |row| row['client_id'] }
      uniq_tax_return_id_sql = <<~SQL
        select tax_returns.id, tax_returns.client_id
        from tax_returns inner join (
          select client_id, max(year) as year from tax_returns
          where client_id in (?) group by client_id
        ) max_year_by_client_id on tax_returns.client_id = max_year_by_client_id.client_id and tax_returns.year = max_year_by_client_id.year
      SQL
      tax_return_ids = TaxReturn.find_by_sql([uniq_tax_return_id_sql, client_ids]).pluck(:id)
      ActiveRecord::Base.transaction do
        selection = TaxReturnSelection.create!
        TaxReturnSelectionTaxReturn.insert_all(
          tax_return_ids.map { |tr_id| { tax_return_id: tr_id, tax_return_selection_id: selection.id } }
        )
        bulk_message_csv.update!(tax_return_selection: selection, status: "ready")
      end
    end
  end
end
