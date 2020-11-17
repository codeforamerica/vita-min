module VitaPartnerHelper
  def grouped_organization_options
    @vita_partners.top_level.collect do |partner|
      [partner.name, [[partner.name, partner.id], *partner.sub_organizations.collect { |v| [v.name, v.id] }]]
    end
  end
end
