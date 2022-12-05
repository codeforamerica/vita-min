class SearchIndexer
  def self.mark_all_clients_for_filter_indexing
    now = Time.current
    base_query = Client.where(needs_to_flush_filterable_properties_set_at: nil)
    puts "#{base_query.count} records to mark..."
    base_query.in_batches(of: 10_000) do |batch|
      batch.update_all(needs_to_flush_filterable_properties_set_at: now)
      print '.'
    end
    puts "done!"
  end

  def self.refresh_all_marked_clients_filterable_properties
    marked_count = Client.where.not(needs_to_flush_filterable_properties_set_at: nil).count
    batch_size = 10_000
    puts "#{marked_count} marked records..."
    (marked_count.to_f / batch_size).ceil.times do|n|
      refresh_filterable_properties(nil, 10_000)
      print '.'
      puts if n % 50 == 0
    end
    puts "done!"
  end

  def self.refresh_filterable_properties(client_ids = nil, limit = 1000)
    ActiveRecord::Base.transaction do
      client_ids =
        if client_ids.nil?
          Client.where('needs_to_flush_filterable_properties_set_at < ?', Time.current).limit(limit).pluck(:id)
        else
          Client.where(id: client_ids)
        end

      attributes = Client.where(id: client_ids).includes(:tax_returns, :documents, intake: :dependents).map do |client|
        {
          id: client.id,
          created_at: client.created_at,
          updated_at: client.updated_at,
          filterable_tax_return_properties: client.tax_returns.map do |tr|
            {
              year: tr.year,
              service_type: tr.service_type,
              current_state: tr.current_state,
              assigned_user_id: tr.assigned_user_id,
              stage: TaxReturnStateMachine::STAGES_BY_STATE[tr.current_state],
              active: tr.current_state.present? && !TaxReturnStateMachine::EXCLUDED_FROM_SLA.include?(tr.current_state&.to_sym),
              greetable: TaxReturnStateMachine.available_states_for(role_type: GreeterRole::TYPE).values.flatten.include?(tr.current_state)
            }
          end,
          filterable_number_of_required_documents_uploaded: client.number_of_required_documents_uploaded,
          filterable_number_of_required_documents: client.number_of_required_documents,
          filterable_percentage_of_required_documents_uploaded: client.number_of_required_documents_uploaded / client.number_of_required_documents.to_f,
          needs_to_flush_filterable_properties_set_at: nil
        }
      end
      return unless attributes.present?

      attributes_to_update = attributes.first.keys - [:id, :created_at, :updated_at]
      Client.upsert_all(attributes, record_timestamps: false, update_only: attributes_to_update)
    end
  end

  def self.refresh_search_index(limit: 10_000)
    now = Time.current
    ids = Intake.where('needs_to_flush_searchable_data_set_at < ?', now)
      .limit(limit)
      .pluck(:id)

    Intake.where(id: ids)
      .where('needs_to_flush_searchable_data_set_at < ?', now)
      .update_all(<<-SQL)
        searchable_data = to_tsvector('simple', array_to_string(ARRAY[#{Intake.searchable_fields.map { |f| "#{f}::text"}.join(",\n") }], ' ', '')),
        needs_to_flush_searchable_data_set_at = NULL
    SQL
  end
end