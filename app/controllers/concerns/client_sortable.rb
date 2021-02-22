module ClientSortable
  def filtered_and_sorted_clients(default_order: nil)
    @default_order = default_order || { "id" => "desc" }
    setup_sortable_client unless @filters.present?
    clients = @clients.after_consent
    clients = clients.delegated_order(@sort_column, @sort_order)
    clients = clients.where(tax_returns: { status: TaxReturnStatus::STATUSES_BY_STAGE[@filters[:stage]] }) if @filters[:stage].present?
    clients = clients.where.not(attention_needed_since: nil) if @filters[:needs_attention].present?
    clients = clients.where(tax_returns: { assigned_user: limited_user_ids }) unless limited_user_ids.empty?
    clients = clients.where(tax_returns: { year: @filters[:year] }) if @filters[:year].present?
    clients = clients.where(tax_returns: { status: @filters[:status] }) if @filters[:status].present?
    if @filters[:vita_partner_id].present?
      id = @filters[:vita_partner_id]
      clients = clients.where('vita_partners.id = ? OR vita_partners.parent_organization_id = ?', id, id)
    end
    clients = clients.where(intake: Intake.search(@filters[:search])) if @filters[:search].present?
    clients
  end

  # see if there are any overlapping keys in the provided params and search/sort set
  def has_search_and_sort_params?
    (params.keys.map(&:to_sym) & search_and_sort_params).any?
  end

  private

  def setup_sortable_client
    reset_filter_params if params[:clear]
    @sort_column = clients_sort_column
    @sort_order = clients_sort_order
    @filters = {
      search: normalize_phone_number_if_present(params[:search]),
      status: status_filter,
      stage: stage_filter,
      assigned_to_me: params[:assigned_to_me],
      unassigned: params[:unassigned],
      needs_attention: params[:needs_attention],
      year: params[:year],
      vita_partner_id: params[:vita_partner_id].present? ? params[:vita_partner_id].to_i : nil
    }
  end

  def search_and_sort_params
    [:search, :status, :unassigned, :assigned_to_me, :needs_attention, :year, :vita_partner_id]
  end

  # reset the raw parameters for each filter received by the form
  def reset_filter_params
    search_and_sort_params.each do |param|
      params[param] = nil
    end
  end

  def clients_sort_order
    %w[asc desc].include?(params[:order]) ? params[:order] : @default_order.values.first
  end

  def clients_sort_column
    sortable_columns = [:id, :updated_at, :first_unanswered_incoming_interaction_at, :attention_needed_since] + Client.sortable_intake_attributes
    sortable_columns.include?(params[:column]&.to_sym) ? params[:column] : @default_order.keys.first
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

  def normalize_phone_number_if_present(full_query)
    return if full_query.nil?

    # Regex tested at https://regex101.com/r/4C0dgE/3
    phone_match = full_query.match(/ ?(?<phone>\(?(\d[ \.\(\)-]{0,2}){10,11})/)
    if phone_match.present?
      phone_numberish_substring = phone_match["phone"]
      full_query = full_query.sub(phone_numberish_substring, PhoneParser.normalize(phone_numberish_substring))
    end

    full_query
  end
end
