class PartnerRoutingService
  attr_accessor :routing_method

  def initialize(source_param: nil, zip_code: nil)
    @source_param = source_param
    @zip_code = zip_code
    @routing_method = nil
  end

  # @return VitaPartner the object of the vita_partner we recommend routing to.
  def determine_partner
    from_source_param = vita_partner_from_source_param if @source_param.present?
    return from_source_param if from_source_param.present?

    from_zip_code = vita_partner_from_zip_code if @zip_code.present?
    return from_zip_code if from_zip_code.present?

    from_state_routing = vita_partner_from_state if @zip_code.present?
    return from_state_routing if from_state_routing.present?

    nil
  end

  private

  def vita_partner_from_source_param
    return false unless @source_param.present?

    source_param_downcase = @source_param.downcase
    vita_partner = SourceParameter.includes(:vita_partner).find_by(code: source_param_downcase)&.vita_partner

    if vita_partner.present?
      @routing_method = :source_param
      vita_partner
    end
  end

  def vita_partner_from_zip_code
    return false unless @zip_code.present?

    eligible_with_capacity = VitaPartnerZipCode.where(zip_code: @zip_code).joins(vita_partner: :organization_capacity).merge(
      OrganizationCapacity.with_capacity
    )

    vita_partner = eligible_with_capacity.first&.vita_partner

    if vita_partner.present?
      @routing_method = :zip_code
      vita_partner
    end
  end

  def vita_partner_from_state
    return false unless @zip_code.present?

    state = ZipCodes.details(@zip_code)[:state]
    eligible_with_capacity = VitaPartnerState.where(state: state).joins(vita_partner: :organization_capacity).merge(
      OrganizationCapacity.with_capacity
    )
    routing_ranges = WeightedRoutingService.new(eligible_with_capacity).weighted_routing_ranges
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

  # TODO: keep this method until we bring it back or discard and search git history?
  def route_to_national_overflow_partner
    vita_partner = VitaPartner.where(national_overflow_location: true).order(Arel.sql('RANDOM()')).first
    if vita_partner.present?
      @routing_method = :national_overflow
      vita_partner
    end
  end
end
