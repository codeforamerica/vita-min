class ClientSorter
  QUICK_FILTERS = [
    [{last_contact: "approaching_sla", active_returns: true}, "Approaching SLA"],
    [{last_contact: "breached_sla", active_returns: true}, "Breached SLA"]
  ]

  attr_reader :current_user
  attr_reader :filters
  attr_reader :sort_column
  attr_reader :sort_order

  def initialize(clients, current_user, params, cookie_filters)
    @clients = clients
    @current_user = current_user
    @params = params
    filter_source = has_search_and_sort_params? ? params : cookie_filters
    @default_order = { "last_outgoing_communication_at" => "asc" }
    @sort_column = clients_sort_column
    @sort_order = clients_sort_order
    @filters = filters_from(filter_source)
  end

  def active_filters
    @filters.select { |_, v| v.present? }
  end

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
    clients = clients.distinct.joins(:intake)
    clients = clients.where(intake: Intake.where(type: "Intake::CtcIntake")) if @filters[:ctc_client].present?
    clients = clients.where(tax_returns: { current_state: TaxReturnStateMachine::STATES_BY_STAGE[@filters[:stage]] }) if @filters[:stage].present?
    clients = clients.where.not(flagged_at: nil) if @filters[:flagged].present?
    clients = clients.where(tax_returns: { assigned_user: limited_user_ids }) unless limited_user_ids.empty?
    clients = clients.where(tax_returns: { year: @filters[:year] }) if @filters[:year].present?
    clients = clients.where(tax_returns: { current_state: @filters[:status] }) if @filters[:status].present?
    clients = clients.where.not(tax_returns: { current_state: TaxReturnStateMachine::EXCLUDED_FROM_SLA }) if @filters[:active_returns].present?
    clients = clients.where("intakes.locale = :language OR intakes.preferred_interview_language = :language", language: @filters[:language]) if @filters[:language].present?
    clients = clients.where(tax_returns: { service_type: @filters[:service_type] }) if @filters[:service_type].present?
    clients = clients.where(vita_partner: VitaPartner.allows_greeters) if @filters[:greetable].present?
    clients = clients.first_unanswered_incoming_interaction_between(...@filters[:sla_breach_date]) if @filters[:sla_breach_date].present?
    clients = clients.where(intake: Intake.where(with_general_navigator: true).or(Intake.where(with_incarcerated_navigator: true)).or(Intake.where(with_limited_english_navigator: true)).or(Intake.where(with_unhoused_navigator: true))) if @filters[:used_navigator].present?

    case @filters[:last_contact]
    when "recently_contacted"
      clients = clients.where("last_outgoing_communication_at > ?", 1.business_days.ago)
    when "approaching_sla"
      clients = clients.where(last_outgoing_communication_at: 6.business_days.ago..4.business_days.ago)
    when "breached_sla"
      clients = clients.where("last_outgoing_communication_at < ?", 6.business_days.ago)
    end

    if @filters[:vita_partners].present?
      ids = JSON.parse(@filters[:vita_partners]).map { |vita_partner| vita_partner["id"] }
      clients = clients.where(vita_partner_id: ids)
    end
    clients = clients.where(intake: Intake.search(@filters[:search])) if @filters[:search].present?
    clients
  end

  # see if there are any overlapping keys in the provided params and search/sort set
  def has_search_and_sort_params?
    overlapping_keys = (@params.keys.map(&:to_sym) & search_and_sort_params)
    hash_params = @params.try(:to_unsafe_h) || @params
    overlapping_keys.any? && hash_params.slice(*overlapping_keys).any? { |_, v| v.present? }
  end

  def filtering_only_by?(filter_values)
    @filters.select { |_k, v| v.present? } == filter_values.transform_values { |v| v.to_s }
  end

  private

  def filters_from(source)
    {
      search: normalize_phone_number_if_present(source[:search]),
      status: status_filter(source),
      stage: stage_filter(source),
      assigned_to_me: source[:assigned_to_me],
      unassigned: source[:unassigned],
      flagged: source[:flagged],
      year: source[:year],
      vita_partners: source[:vita_partners]&.to_s,
      assigned_user_id: source[:assigned_user_id]&.to_s,
      language: source[:language],
      service_type: source[:service_type],
      greetable: source[:greetable],
      sla_breach_date: source[:sla_breach_date],
      used_navigator: source[:used_navigator],
      ctc_client: source[:ctc_client],
      last_contact: source[:last_contact],
      active_returns: source[:active_returns],
    }
  end

  def search_and_sort_params
    [
      :search,
      :status,
      :unassigned,
      :assigned_to_me,
      :flagged,
      :unemployment_income,
      :year,
      :vita_partners,
      :assigned_user_id,
      :language,
      :service_type,
      :greetable,
      :sla_breach_date,
      :used_navigator,
      :ctc_client,
      :last_contact,
      :active_returns,
    ]
  end

  def clients_sort_order
    %w[asc desc].include?(@params[:order]) ? @params[:order] : @default_order.values.first
  end

  def clients_sort_column
    sortable_columns = [:id, :updated_at, :first_unanswered_incoming_interaction_at, :last_outgoing_communication_at] + Client.sortable_intake_attributes
    sortable_columns.include?(@params[:column]&.to_sym) ? @params[:column] : @default_order.keys.first
  end

  def status_filter(source)
    TaxReturnStateMachine.states.find { |state| state == source[:status] }
  end

  def stage_filter(source)
    TaxReturnStateMachine::STAGES.find { |stage| stage == source[:status] }
  end

  def limited_user_ids
    val = []
    val.push(current_user.id) if @filters[:assigned_to_me].present?
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
