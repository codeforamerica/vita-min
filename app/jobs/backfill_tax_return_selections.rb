class BackfillTaxReturnSelections < ApplicationJob
  def perform(start: 0, finish: nil)
    ClientSelection.includes(:clients).find_each(start: start, finish: finish) do |client_selection|
      tax_return_selection = TaxReturnSelection.create(tax_returns: client_selection.clients.map(&:tax_returns).flatten)
      if tax_return_selection.valid?
        puts "SUCCESS creating tax return selection #{tax_return_selection.id} from client selection #{client_selection.id}"
      else
        puts "ERROR creating tax return selection #{tax_return_selection.id} from client selection #{client_selection.id}"
      end

      messages = BulkClientMessage.where(client_selection: client_selection)
      messages.each do |message|
        if message.update(tax_return_selection_id: tax_return_selection.id)
          puts "SUCCESS associating tax return selection #{tax_return_selection.id} with bulk message #{message.id}"
        else
          puts "ERROR associating tax return selection #{tax_return_selection.id} with bulk message #{message.id}"
        end
      end

      notes = BulkClientNote.where(client_selection: client_selection)
      notes.each do |note|
        if note.update(tax_return_selection_id: tax_return_selection.id)
          puts "SUCCESS associating tax return selection #{tax_return_selection.id} with bulk note #{note.id}"
        else
          puts "ERROR associating tax return selection #{tax_return_selection.id} with bulk note #{note.id}"
        end
      end

      org_changes = BulkClientOrganizationUpdate.where(client_selection: client_selection)
      org_changes.each do |org_change|
        if org_change.update(tax_return_selection_id: tax_return_selection.id)
          puts "SUCCESS associating tax return selection #{tax_return_selection.id} with bulk org change #{org_change.id}"
        else
          puts "ERROR associating tax return selection #{tax_return_selection.id} with bulk org change #{org_change.id}"
        end
      end
    end
  end
end