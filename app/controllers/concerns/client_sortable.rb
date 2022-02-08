module ClientSortable
  def filtered_and_sorted_clients(default_order: nil)
    @default_order = default_order
    setup_sortable_client unless @filters.present?
    filtered_clients.delegated_order(@sort_column, @sort_order)
  end

  def filtered_clients
    clients = if current_user&.greeter?
                # Greeters should only have "search" access to clients in intake stage AND clients assigned to them.
                @clients.greetable || Client.joins(:tax_returns).where(tax_returns: { assigned_user: current_user }).distinct
              else
                @clients.after_consent
              end
    # Force an inner join to `intakes` to exclude clients from previous years
    clients = clients.joins(:intake)
    clients = clients.where(intake: Intake.where(type: "Intake::CtcIntake")) if @filters[:ctc_client].present?
    clients = clients.where(tax_returns: { state: TaxReturnStateMachine::STATES_BY_STAGE[@filters[:stage]] }) if @filters[:stage].present?
    clients = clients.where.not(flagged_at: nil) if @filters[:flagged].present?
    clients = clients.where(tax_returns: { assigned_user: limited_user_ids }) unless limited_user_ids.empty?
    clients = clients.where(tax_returns: { year: @filters[:year] }) if @filters[:year].present?
    clients = clients.where(tax_returns: { state: @filters[:status] }) if @filters[:status].present?
    clients = clients.where("intakes.locale = :language OR intakes.preferred_interview_language = :language", language: @filters[:language]) if @filters[:language].present?
    clients = clients.where(tax_returns: { service_type: @filters[:service_type] }) if @filters[:service_type].present?
    clients = clients.where(intake: Intake.where(had_unemployment_income: "yes")) if @filters[:unemployment_income].present?
    clients = clients.where(vita_partner: VitaPartner.allows_greeters) if @filters[:greetable].present?
    clients = clients.first_unanswered_incoming_interaction_communication_breaches(@filters[:sla_breach_date]) if @filters[:sla_breach_date].present?
    clients = clients.where(intake: Intake.where(with_general_navigator: true).or(Intake.where(with_incarcerated_navigator: true)).or(Intake.where(with_limited_english_navigator: true)).or(Intake.where(with_unhoused_navigator: true))) if @filters[:used_navigator].present?

    if @filters[:vita_partners].present?
      ids = JSON.parse(@filters[:vita_partners]).map { |vita_partner| vita_partner["id"] }
      clients = clients.where(vita_partner_id: ids)
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
    @default_order = { "last_outgoing_communication_at" => "asc" }
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
      flagged: source[:flagged],
      unemployment_income: source[:unemployment_income],
      year: source[:year],
      vita_partners: source[:vita_partners]&.to_s,
      assigned_user_id: source[:assigned_user_id]&.to_s,
      language: source[:language],
      service_type: source[:service_type],
      greetable: source[:greetable],
      sla_breach_date: source[:sla_breach_date],
      used_navigator: source[:used_navigator],
      ctc_client: source[:ctc_client],
    }
  end

  def search_and_sort_params
    [:search, :status, :unassigned, :assigned_to_me, :flagged, :unemployment_income, :year, :vita_partners, :assigned_user_id, :language, :service_type, :greetable, :sla_breach_date, :used_navigator, :ctc_client]
  end

  def cookie_filters
    return {} unless filter_cookie_name.present?

    cookies[filter_cookie_name] ? HashWithIndifferentAccess.new(JSON.parse(cookies[filter_cookie_name])) : {}
  end

  def clients_sort_order
    %w[asc desc].include?(params[:order]) ? params[:order] : @default_order.values.first
  end

  def clients_sort_column
    sortable_columns = [:id, :updated_at, :first_unanswered_incoming_interaction_at, :last_outgoing_communication_at] + Client.sortable_intake_attributes
    sortable_columns.include?(params[:column]&.to_sym) ? params[:column] : @default_order.keys.first
  end

  def status_filter(source)
    TaxReturnStateMachine.states.find { |state| state == source[:status] }
  end

  def stage_filter(source)
    TaxReturnStateMachine::STAGES.find { |stage| stage == source[:status] }
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

    # Regex tested at https://regex101.com/r/2K13UX/1/
    phone_match = full_query.match(/ ?(?<phone>\+?\(?(\d[ \.\(\)-]{0,2}){10,11})/)
    if phone_match.present?
      phone_numberish_substring = phone_match["phone"]
      full_query = full_query.sub(phone_numberish_substring, PhoneParser.normalize(phone_numberish_substring))
    end

    full_query
  end
end
