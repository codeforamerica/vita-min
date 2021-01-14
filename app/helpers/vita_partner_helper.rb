module VitaPartnerHelper
  def grouped_organization_options
    @vita_partners.organizations.collect do |partner|
      [partner.name, [[partner.name, partner.id], *partner.child_sites.collect { |v| [v.name, v.id] }]]
    end
  end
end
