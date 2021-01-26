class PartnerRoutingService
  attr_accessor :routing_method

  def initialize(source_param: nil, zip_code: nil)
    @source_param = source_param
    @zip_code = zip_code
    @routing_method = nil
  end

  # @return VitaPartner the object of the vita_partner we recommend routing to.
  def determine_partner
    return vita_partner_from_source_param if @source_param.present? && vita_partner_from_source_param.present?

    return vita_partner_from_zip_code if @zip_code.present? && vita_partner_from_zip_code.present?

    return vita_partner_from_state if @zip_code.present? && vita_partner_from_state.present?

    route_to_national_overflow_partner
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

    vita_partner = VitaPartnerZipCode.where(zip_code: @zip_code).first&.vita_partner

    if vita_partner.present?
      @routing_method = :zip_code
      vita_partner
    end
  end

  def vita_partner_from_state
    return false unless @zip_code.present?

    state = ZipCodes.details(@zip_code)[:state]
    vita_partners_for_state = VitaPartnerState.where(state: state)
    return if vita_partners_for_state.nil?

    vps_options = vita_partners_for_state.first.state_routing_options
    num = Random.rand(0..1.0)

    vita_partner_id = for i in 1..vps_options.count do
      # between vps_options[i-1] && vps_options[i]

      if i == 1
        low_range = 0
        high_range = vps_options[i][1]
      end

      low_range = vps_options[i][1] unless low_range == 0
      high_range = vps_options[i+1][1] if high_range.nil?

      return vps_options[i][0] if num.between?(low_range, high_range)
    end

    #get routing options [[id, fraction], [id, fraction]]
    #
    # does the order of these ranges matter?
    # in VitaPartnerStates.where(state: "CA").pluck(:vita_partner_id)
    # .3 / sum = .2
    #
    # 0.3, 0.2, 0.5
    # 0.0-0.3; 0.3-0.5; 0.5-1.0
    # rand 0-1 => .2

    vita_partner = VitaPartner.find(vita_partner_id)
    if vita_partner.present?
      @routing_method = :state
      vita_partner
    end
  end

  # TODO: What happens in the case that there are no national overflow partners? Is there a GYR organization we can route them to?
  def route_to_national_overflow_partner
    vita_partner = VitaPartner.where(national_overflow_location: true).order(Arel.sql('RANDOM()')).first
    if vita_partner.present?
      @routing_method = :national_overflow
      vita_partner
    end
  end
end