class PartnerRoutingService
  attr_accessor :routing_method

  def initialize(intake: nil, source_param: nil, zip_code: nil)
    @source_param = source_param
    @zip_code = zip_code
    @intake = intake
    @routing_method = nil
  end

  # @return VitaPartner the object of the vita_partner we recommend routing to.
  def determine_partner
    from_previous_year_partner = previous_year_partner
    return from_previous_year_partner if from_previous_year_partner.present?

    from_source_param = vita_partner_from_source_param if @source_param.present?
    return from_source_param if from_source_param.present?

    from_zip_code = vita_partner_from_zip_code if @zip_code.present?
    return from_zip_code if from_zip_code.present?

    from_state_routing = vita_partner_from_state if @zip_code.present?
    return from_state_routing if from_state_routing.present?

    from_national_routing = route_to_national_overflow_partner
    return from_national_routing if from_national_routing.present?

    @routing_method = :at_capacity
    return
  end

  private

  def previous_year_partner
    return false unless @intake

    vita_partner = @intake.probable_previous_year_intake&.vita_partner

    if vita_partner.present? && vita_partner.active?
      @routing_method = :returning_client
      vita_partner
    end
  end

  def vita_partner_from_source_param
    return unless @source_param.present?

    source_param_downcase = @source_param.downcase
    vita_partner = SourceParameter.includes(:vita_partner).find_by(code: source_param_downcase)&.vita_partner

    if vita_partner.present?
      @routing_method = :source_param
      vita_partner
    end
  end

  def vita_partner_from_zip_code
    return unless @zip_code.present?

    eligible_with_capacity = VitaPartnerZipCode.where(zip_code: @zip_code).joins(organization: :organization_capacity).merge(
      OrganizationCapacity.with_capacity
    )

    vita_partner = eligible_with_capacity.first&.vita_partner

    if vita_partner.present?
      @routing_method = :zip_code
      vita_partner
    end
  end

  def vita_partner_from_state
    return unless @zip_code.present?

    state = ZipCodes.details(@zip_code)[:state]
    in_state_routing_fractions = StateRoutingFraction.joins(:state_routing_target)
                                                     .where(state_routing_targets: { state_abbreviation: state })
    # get state routing fractions associated with organizations that have capacity
    with_capacity_organization_fractions = in_state_routing_fractions
                                             .joins(organization: :organization_capacity)
                                             .merge(
                                               OrganizationCapacity.with_capacity
                                             )
    # get state routing fractions associated with sites whose parent organizations have capacity
    site_fractions = in_state_routing_fractions.joins(:site)
    site_parent_ids = site_fractions.map(&:site).pluck(:parent_organization_id)
    parents_with_capacity_ids = OrganizationCapacity.with_capacity.where(organization: site_parent_ids).pluck(:vita_partner_id)
    with_capacity_site_fractions = site_fractions.where(site: { parent_organization_id: parents_with_capacity_ids })

    routing_ranges = WeightedRoutingService.new(with_capacity_site_fractions + with_capacity_organization_fractions).weighted_routing_ranges
    random_num = Random.rand(0..1.0)
    vita_partner_id = routing_ranges.map do |range|
      range[:id] if random_num.between?(range[:low], range[:high])
    end
    vita_partner = VitaPartner.where(id: vita_partner_id)&.first
    if vita_partner.present?
      @routing_method = :state
      vita_partner
    end
  end

  def route_to_national_overflow_partner
    national_overflow_locations = VitaPartner.where(national_overflow_location: true).order(Arel.sql('RANDOM()'))
    vita_partner = national_overflow_locations.first
    if vita_partner.present?
      @routing_method = :national_overflow
      vita_partner
    end
  end
end