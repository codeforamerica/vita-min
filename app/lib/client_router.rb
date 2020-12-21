class ClientRouter
  def self.route(client)
    organization_with_most_users = OrganizationLeadRole.group(:id).group("vita_partner_id").order('COUNT(user) DESC').first.organization
    client.update(vita_partner: organization_with_most_users)
    client.intake.update(vita_partner: organization_with_most_users)
  end
end
