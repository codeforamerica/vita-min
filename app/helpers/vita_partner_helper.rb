module VitaPartnerHelper
  def grouped_vita_partner_options
    result = {}
    @vita_partners.each do |partner|
      organization_name = partner.type == Organization::TYPE ? partner.name : partner.parent_organization.name
      result[organization_name] ||= []
      result[organization_name].push([partner.name, partner.id]) if partner.site?
      result[organization_name].unshift([partner.name, partner.id]) if partner.organization?
    end
    result.to_a
  end
end
