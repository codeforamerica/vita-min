module ClientSortable
  def filtered_and_sorted_clients(default_order: nil)
    @default_order = default_order || { "response_needed_since" => "asc" }
    setup_sortable_client unless @filters.present?
    clients = if current_user&.greeter?
              # Greeters should only have "search" access to clients in intake stage AND clients assigned to them.
                @clients.in_intake.or(Client.joins(:tax_returns).where(tax_returns: { assigned_user: current_user }).distinct)
              else
                @clients.after_consent
              end
    clients = clients.delegated_order(@sort_column, @sort_order)
    clients = clients.where(tax_returns: { status: TaxReturnStatus::STATUSES_BY_STAGE[@filters[:stage]] }) if @filters[:stage].present?
    clients = clients.where.not(response_needed_since: nil) if @filters[:needs_response].present?
    clients = clients.where(tax_returns: { assigned_user: limited_user_ids }) unless limited_user_ids.empty?
    clients = clients.where(tax_returns: { year: @filters[:year] }) if @filters[:year].present?
    clients = clients.where(tax_returns: { status: @filters[:status] }) if @filters[:status].present?
    clients = clients.where("intakes.locale = :language OR intakes.preferred_interview_language = :language", language: @filters[:language]) if @filters[:language].present?
    clients = clients.where(tax_returns: { service_type: @filters[:service_type] }) if @filters[:service_type].present?
    clients = clients.where(intake: Intake.where(had_unemployment_income: "yes")) if @filters[:unemployment_income].present?

    if @filters[:vita_partner_id].present?
      id = @filters[:vita_partner_id].to_i
      clients = clients.where('vita_partners.id = :id OR vita_partners.parent_organization_id = :id', id: id)
    end
    clients = clients.where(intake: Intake.search(@filters[:search])) if @filters[:search].present?
    clients
  end

  # see if there are any overlapping keys in the provided params and search/sort set
  def has_search_and_sort_params?
    overlapping_keys = (params.keys.map(&:to_sym) & search_and_sort_params)
    hash_params = params.try(:to_unsafe_h) || params
    overlapping_keys.any? && hash_params.slice(*overlapping_keys).any? { |_, v| v.present? }
  end

  private

  def setup_sortable_client
    delete_cookie if params[:clear]
    @sort_column = clients_sort_column
    @sort_order = clients_sort_order
    filter_source = has_search_and_sort_params? ? params : cookie_filters
    @filters = filters_from(filter_source)
    set_cookie
  end

  def delete_cookie
    cookies.delete(filter_cookie_name) if filter_cookie_name.present?
  end

  def set_cookie
    cookies[filter_cookie_name] = JSON.generate(@filters.select { |_, v| v.present? }) if filter_cookie_name.present?
  end

  def filters_from(source)
    {
      search: normalize_phone_number_if_present(source[:search]),
      status: status_filter(source),
      stage: stage_filter(source),
      assigned_to_me: source[:assigned_to_me],
      unassigned: source[:unassigned],
      needs_response: source[:needs_response],
      unemployment_income: source[:unemployment_income],
      year: source[:year],
      vita_partner_id: source[:vita_partner_id]&.to_s,
      assigned_user_id: source[:assigned_user_id]&.to_s,
      language: source[:language],
      service_type: source[:service_type]
    }
  end

  def search_and_sort_params
    [:search, :status, :unassigned, :assigned_to_me, :needs_response, :unemployment_income, :year, :vita_partner_id, :assigned_user_id, :language, :service_type]
  end

  def cookie_filters
    return {} unless filter_cookie_name.present?

    cookies[filter_cookie_name] ? HashWithIndifferentAccess.new(JSON.parse(cookies[filter_cookie_name])) : {}
  end

  def clients_sort_order
    %w[asc desc].include?(params[:order]) ? params[:order] : @default_order.values.first
  end

  def clients_sort_column
    sortable_columns = [:id, :updated_at, :first_unanswered_incoming_interaction_at, :response_needed_since] + Client.sortable_intake_attributes
    sortable_columns.include?(params[:column]&.to_sym) ? params[:column] : @default_order.keys.first
  end

  def status_filter(source)
    TaxReturnStatus::STATUSES.keys.find { |status| status == source[:status]&.to_sym }
  end

  def stage_filter(source)
    TaxReturnStatus::STAGES.find { |stage| stage == source[:status] }
  end

  def limited_user_ids
    val = []
    val.push(current_user.id) if @filters[:assigned_to_me].present? || @always_current_user_assigned
    val.push(@filters[:assigned_user_id].to_i) if @filters[:assigned_user_id].present?
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
