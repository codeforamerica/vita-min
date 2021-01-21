class RoutingService
  attr_accessor :source_param, :routing_method

  def initialize(source_param: nil, zip_code: nil)
    @source_param = source_param
    @zip_code = zip_code
    @routing_method = nil
  end

  # @return VitaPartner the object of the vita_partner we recommend routing to.
  def determine_organization
    return route_from_source_param if route_from_source_param.present?

    # add zip_code routing logic here
    fallback_organization
  end

  private

  def route_from_source_param
    return false unless source_param.present?

    vita_partner = SourceParameter.includes(:vita_partner).find_by(code: source_param)&.vita_partner

    if vita_partner.present?
      @routing_method = :source_param
      vita_partner
    end
  end

  def vita_partner_from_zip_code
    # @routing_method = :zip_code
  end

  # This fallback logic SHOULD BE REMOVED once all routing tickets are implemented --
  # Yes -- this does a query to get the id and then a second query to load the vita partner.
  # However, we're removing this logic soon so it should be fine for a temporary fix to have a VitaPartner object
  # As a return value
  def fallback_organization
    organization_id_with_most_leads = ActiveRecord::Base.connection.execute(
        "SELECT vita_partners.id FROM vita_partners LEFT JOIN organization_lead_roles on vita_partners.id=organization_lead_roles.vita_partner_id GROUP BY vita_partners.id ORDER BY count(organization_lead_roles.id) DESC LIMIT 1").first["id"]
    @routing_method = :most_org_leads
    VitaPartner.find(organization_id_with_most_leads)
  end
end