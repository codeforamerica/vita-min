class ClientRouter
  def self.route(client)
    organization_id_with_most_leads = ActiveRecord::Base.connection.execute(
      "SELECT vita_partners.id FROM vita_partners LEFT JOIN organization_lead_roles on vita_partners.id=organization_lead_roles.vita_partner_id GROUP BY vita_partners.id ORDER BY count(organization_lead_roles.id) DESC LIMIT 1").first["id"]
    client.update(vita_partner_id: organization_id_with_most_leads)
    client.intake.update(vita_partner_id: organization_id_with_most_leads)
  end
end
