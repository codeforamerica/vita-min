module ClientSortable

  def setup_sortable_client
    params[:status] = nil if params[:clear]
    @sort_column = clients_sort_column
    @sort_order = clients_sort_order
    @filters = { status: clients_tax_return_status_filter, stage: clients_tax_return_stage_filter }
  end

  def clients_sort_order
    %w[asc desc].include?(params[:order]) ? params[:order] : "desc"
  end

  def clients_sort_column
    %w[preferred_name id updated_at locale].include?(params[:column]) ? params[:column] : "id"
  end

  def clients_tax_return_status_filter
    TaxReturnStatus::STATUSES.keys.find { |status| status == params[:status]&.to_sym }
  end

  def clients_tax_return_stage_filter
    TaxReturnStatus::STAGES.find { |stage| stage == params[:status] }
  end

  def filtered_and_sorted_clients(assigned_to: nil)
    clients = @clients.after_consent
    clients = clients.delegated_order(@sort_column, @sort_order)
    clients = clients.assigned_to(assigned_to.id) if assigned_to.present?
    clients = clients.where(tax_returns: { status: TaxReturnStatus::STATUSES_BY_STAGE[@filters[:stage]] }) if @filters[:stage].present?
    clients = clients.where(tax_returns: { status: @filters[:status] }) if @filters[:status].present?
    clients
  end
end