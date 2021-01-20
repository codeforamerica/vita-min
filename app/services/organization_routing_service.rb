class OrganizationRoutingService
  attr_accessor :referring_organization_id, :routing_method

  def initialize(referring_organization_id: nil, zip_code: zip_code)
    @referring_organization_id = referring_organization_id
    @zip_code = zip_code
    @routing_method = nil
  end

  # @return VitaPartner the object of the vita_partner we recommend routing to.
  def determine_organization
    return vita_partner_from_referring_organization if vita_partner_from_referring_organization.present?
    # add zip_code routing logic here
    fallback_organization
  end

  private

  def vita_partner_from_referring_organization
    if referring_organization_id.present?
      @routing_method = :direct
      VitaPartner.find(referring_organization_id)
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