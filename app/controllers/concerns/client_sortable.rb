module ClientSortable
  def filtered_and_sorted_clients
    setup_sortable_client unless @filters.present?
    clients = @clients.after_consent
    clients = clients.delegated_order(@sort_column, @sort_order)
    clients = clients.where(tax_returns: { status: TaxReturnStatus::STATUSES_BY_STAGE[@filters[:stage]] }) if @filters[:stage].present?
    clients = clients.where.not(response_needed_since: nil) if @filters[:needs_response].present?
    clients = clients.where(tax_returns: { assigned_user: limited_user_ids }) unless limited_user_ids.empty?
    clients = clients.where(tax_returns: { year: @filters[:year] }) if @filters[:year].present?
    clients = clients.where(tax_returns: { status: @filters[:status] }) if @filters[:status].present?
    clients = clients.where(intake: Intake.search(@filters[:search])) if @filters[:search].present?
    clients
  end

  private

  def setup_sortable_client
    reset_filter_params if params[:clear]
    @sort_column = clients_sort_column
    @sort_order = clients_sort_order
    @filters = {
      search: params[:search],
      status: status_filter,
      stage: stage_filter,
      assigned_to_me: params[:assigned_to_me],
      unassigned: params[:unassigned],
      needs_response: params[:needs_response],
      year: params[:year]
    }
  end

  # reset the raw parameters for each filter received by the form
  def reset_filter_params
    params[:status] = nil
    params[:unassigned] = nil
    params[:assigned_to_me] = nil
    params[:needs_response] = nil
    params[:year] = nil
  end

  def clients_sort_order
    %w[asc desc].include?(params[:order]) ? params[:order] : "desc"
  end

  def clients_sort_column
    %w[preferred_name id updated_at locale].include?(params[:column]) ? params[:column] : "id"
  end

  def status_filter
    TaxReturnStatus::STATUSES.keys.find { |status| status == params[:status]&.to_sym }
  end

  def stage_filter
    TaxReturnStatus::STAGES.find { |stage| stage == params[:status] }
  end

  def limited_user_ids
    val = []
    val.push(current_user.id) if @filters[:assigned_to_me].present? || @always_current_user_assigned
    val.push(nil) if @filters[:unassigned].present?
    val
  end
end