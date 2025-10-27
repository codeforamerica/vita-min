class PartnerRoutingService
  attr_accessor :routing_method
  TESTING_AT_CAPACITY_ZIP_CODE = "83011"

  def self.update_intake_partner(intake)
    routing_service = PartnerRoutingService.new(
      intake: intake,
      source_param: intake.source,
      zip_code: intake.zip_code,
      )
    intake.client.update(vita_partner: routing_service.determine_partner, routing_method: routing_service.routing_method)
  end

  def initialize(intake: nil, source_param: nil, zip_code: nil)
    @source_param = source_param
    @zip_code = zip_code
    @intake = intake
    @routing_method = nil
  end

  # @return VitaPartner the object of the vita_partner we recommend routing to.
  def determine_partner
    unless Rails.env.production?
      if @zip_code.to_s == TESTING_AT_CAPACITY_ZIP_CODE
        @routing_method = :at_capacity
        return
      end
    end

    from_itin_enabled = vita_partner_from_itin_enabled if @intake.present? && @intake.itin_applicant?
    return from_itin_enabled if from_itin_enabled.present?

    from_source_param = vita_partner_from_source_param if @source_param.present?
    return from_source_param if from_source_param.present?

    from_previous_year_partner = previous_year_partner
    return from_previous_year_partner if from_previous_year_partner.present?

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

    if vita_partner.present? && vita_partner.active? && !vita_partner.at_capacity?
      @routing_method = :returning_client
      vita_partner
    end
  end

  def vita_partner_from_source_param
    return unless @source_param.present?

    vita_partner = SourceParameter.find_vita_partner_by_code(@source_param.downcase)

    if vita_partner.present?
      @routing_method = :source_param
      vita_partner
    end
  end

  def vita_partner_from_itin_enabled
    return unless @intake && @intake.itin_applicant?

    state = ZipCodes.details(@zip_code)[:state]
    active_vita_partners_ids_in_state = StateRoutingFraction.joins(:state_routing_target)
                                                            .where(state_routing_targets: { state_abbreviation: state })
                                                            .where("routing_fraction > ?", 0).pluck(:vita_partner_id)

    active_vita_partners_in_state_itin_enabled = VitaPartner.where(id: active_vita_partners_ids_in_state, accepts_itin_applicants: true)

    if active_vita_partners_in_state_itin_enabled.present?
      @routing_method = :itin_enabled
      return active_vita_partners_in_state_itin_enabled.order(Arel.sql('RANDOM()')).first
    end

    # look for any active ITIN enabled partner if none are available in applicant's state
    active_vita_partners_itin_enabled = VitaPartner.joins(:state_routing_fractions)
                                                   .where(["state_routing_fractions.routing_fraction > ?", 0])
                                                   .where(accepts_itin_applicants: true)
    if active_vita_partners_itin_enabled.present?
      @routing_method = :itin_enabled
      active_vita_partners_itin_enabled.order(Arel.sql('RANDOM()')).first
    end
  end

  def vita_partner_from_zip_code
    return unless @zip_code.present?

    eligible_with_capacity = Organization.with_capacity.joins(:serviced_zip_codes).
      where(vita_partner_zip_codes: { zip_code: @zip_code })
    vita_partner = eligible_with_capacity.first

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
    organization_ids_with_capacity = Organization.with_capacity.pluck('id')
    with_capacity_organization_fractions = in_state_routing_fractions
      .joins(:organization)
      .where(organization: organization_ids_with_capacity)
    # get state routing fractions associated with sites whose parent organizations have capacity
    site_fractions = in_state_routing_fractions.joins(:site).includes(:site)
    site_parent_ids = site_fractions.map { |fraction| fraction.site.parent_organization_id }
    parents_with_capacity_ids = organization_ids_with_capacity.intersection(site_parent_ids)
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
    national_overflow_locations = VitaPartner.with_capacity.where(national_overflow_location: true).order(Arel.sql('RANDOM()'))
    vita_partner = national_overflow_locations.first

    if vita_partner.present?
      @routing_method = :national_overflow
      vita_partner
    end
  end
end
