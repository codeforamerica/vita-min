module TaggingHelper
  def taggable_vita_partners(vita_partners)
    taggable_vita_partners = []
    vita_partners.organizations.each do |vita_partner|
      taggable_vita_partners << { id: vita_partner.id, name: vita_partner.name, value: vita_partner.id }
      vita_partner.child_sites.each do |site|
        taggable_vita_partners << { id: site.id, name: site.name, parentName: vita_partner.name, value: site.id }
      end
    end
    taggable_vita_partners.to_json.to_s.html_safe
  end
end