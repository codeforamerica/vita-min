module VitaPartnerHelper
  def grouped_vita_partner_options
    if current_user.role_type == TeamMemberRole::TYPE || current_user.role_type == SiteCoordinatorRole::TYPE
      vita_partner = @vita_partners.first
      [
        [
          vita_partner.parent_organization.name,
          [
            [vita_partner.name, vita_partner.id]
          ]
        ]
      ]
    elsif current_user.greeter? || current_user.admin? || current_user.role_type == CoalitionLeadRole::TYPE || current_user.role_type == OrganizationLeadRole::TYPE
      @vita_partners.organizations.collect do |partner|
        [partner.name, [[partner.name, partner.id], *partner.child_sites.collect { |v| [v.name, v.id] }]]
      end
    end
  end
end
