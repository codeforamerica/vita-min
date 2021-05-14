module TaxReturnAssignableUsers
  def assignable_users(client, included_users = [])
    assignable_users = included_users
    if client.vita_partner.present?
      if client.vita_partner.site?
        team_members = User.where(role: TeamMemberRole.where(site: client.vita_partner))
        site_coordinators = User.where(role: SiteCoordinatorRole.where(site: client.vita_partner))
        assignable_users += team_members.or(site_coordinators).active.order(name: :asc)
      else # client.vita_partner is an organization
        org_leads = User.where(role: OrganizationLeadRole.where(organization: client.vita_partner))
        assignable_users += org_leads.active.order(name: :asc)
      end
    end
    assignable_users.compact.uniq
  end
end
