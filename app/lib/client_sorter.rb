class ClientSorter
  QUICK_FILTERS = [
    [{ last_contact: "approaching_sla", active_returns: true }, "Approaching SLA"],
    [{ last_contact: "breached_sla", active_returns: true }, "Breached SLA"]
  ]

  attr_reader :current_user
  attr_reader :filters
  attr_reader :sort_column
  attr_reader :sort_order

  def initialize(clients, current_user, params, cookie_filters, use_product_year = true)
    @clients = clients
    @current_user = current_user
    @params = params
    filter_source = has_search_and_sort_params? ? params : cookie_filters
    @default_order = { "last_outgoing_communication_at" => "asc" }
    @sort_column = clients_sort_column
    @sort_order = clients_sort_order
    @filters = filters_from(filter_source)
    @use_product_year = use_product_year
  end

  def active_filters
    @filters.select { |_, v| v.present? }
  end

  def filtered_and_sorted_clients(default_order: nil)
    @default_order = default_order
    filtered_clients.delegated_order(@sort_column, @sort_order)
  end

  def filtered_clients
    clients = if current_user&.greeter?
                @clients
              else
                @clients.after_consent
              end
    # Filter on product_year to only show clients who used this-year's product
    if @use_product_year
      clients = clients.where(filterable_product_year: Rails.configuration.product_year)
    end
    clients = clients.where(intake: Intake.where(type: "Intake::CtcIntake")) if @filters[:ctc_client].present?
    clients = clients.where.not(flagged_at: nil) if @filters[:flagged].present?

    tax_return_filters = {}
    if @filters[:stage].present?
      tax_return_filters[:stage] = @filters[:stage]
    end
    if @filters[:year].present?
      tax_return_filters[:year] = @filters[:year].to_i
    end
    if @filters[:status].present?
      tax_return_filters[:current_state] = @filters[:status]
    end
    if @filters[:active_returns].present?
      tax_return_filters[:active] = @filters[:active_returns].in?([true, "true"])
    end
    if @filters[:service_type].present?
      tax_return_filters[:service_type] = @filters[:service_type]
    end

    tax_return_filters_expanded = []

    if limited_user_ids.present?
      special_tax_return_filters = current_user&.greeter? ? tax_return_filters.merge(greetable: true) : tax_return_filters
      limited_user_ids.each do |id|
        tax_return_filters_expanded << special_tax_return_filters.merge(assigned_user_id: id)
      end
    elsif current_user&.greeter?
      tax_return_filters_expanded = [tax_return_filters.merge(greetable: true), tax_return_filters.merge(assigned_user_id: current_user.id)]
    elsif tax_return_filters.present?
      tax_return_filters_expanded = [tax_return_filters]
    end

    if tax_return_filters_expanded.present?
      clients = tax_return_filters_expanded.map do |tax_return_filters|
        clients.where("filterable_tax_return_properties @> ?::jsonb", [tax_return_filters].to_json)
      end.reduce do |all_queries, this_query|
        all_queries.or(this_query)
      end
    end

    clients = clients.where(intake: Intake.where(locale: @filters[:language]).or(Intake.where(preferred_interview_language: @filters[:language]))) if @filters[:language].present?
    clients = clients.where(vita_partner: VitaPartner.allows_greeters) if @filters[:greetable].present?
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
      # For backwards compatibility for users in the middle of a search while this is deployed,
      # we support both hash and number (In future only number will be needed)
      ids = JSON.parse(@filters[:vita_partners]).map do |vita_partner|
        vita_partner.instance_of?(Hash) ? vita_partner["id"] : vita_partner
      end
      clients = clients.where(vita_partner_id: ids)
    end
    clients = clients.where(intake: Intake.search(@filters[:search])) if @filters[:search].present?
    clients
  end

  # see if there are any overlapping keys in the provided params and search/sort set
  def has_search_and_sort_params?
    overlapping_keys = (@params.keys.map(&:to_sym) & search_and_sort_params)
    overlapping_keys.any?
  end

  def filtering_only_by?(filter_values, ignore: [])
    @filters.except(*ignore).select { |_k, v| v.present? } == filter_values.transform_values { |v| v.to_s }
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
    sortable_columns = [
      :id, :updated_at, :filterable_percentage_of_required_documents_uploaded,
      :first_unanswered_incoming_interaction_at, :last_outgoing_communication_at
    ] + Client.sortable_intake_attributes
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
