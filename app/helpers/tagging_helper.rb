module TaggingHelper
  def taggable_vita_partners(vita_partners)
    taggable_vita_partners = []
    # We query via the Organization model to trigger auto-loading of child_sites per Organization model's default scope.
    Organization.where(id: vita_partners.organizations).each do |organization|
      taggable_vita_partners << { id: organization.id, name: organization.name, value: organization.id }
      organization.child_sites.each do |site|
        taggable_vita_partners << { id: site.id, name: site.name, parentName: organization.name, value: site.id }
      end
    end

    return taggable_sites(vita_partners) if taggable_vita_partners.empty?

    taggable_format(taggable_vita_partners)
  end

  def taggable_sites(vita_partners)
    taggable_vita_partners = vita_partners.sites.includes(:parent_organization).map do |site|
      { id: site.id, name: site.name, parentName: site.parent_organization.name, value: site.id }
    end
    taggable_format(taggable_vita_partners)
  end

  def taggable_states(state_abbreviations)
    state_abbreviations.map { |abbreviation| { value: abbreviation, name: States.name_for_key(abbreviation)} }.to_json.html_safe
  end

  def taggable_independent_organizations(organizations)
    taggable_orgs = []
    organizations.each do |vita_partner|
      name = sanitize(strip_tags(vita_partner.name))
      taggable_orgs << { id: vita_partner.id, name: name, value: vita_partner.id }
    end
    taggable_format(taggable_orgs)
  end

  def taggable_organizations(vita_partners)
    taggable_orgs = []
    Organization.where(id: vita_partners.organizations).each do |vita_partner|
      name = sanitize(strip_tags(vita_partner.name))
      taggable_orgs << { id: vita_partner.id, name: name, value: vita_partner.id }
    end
    taggable_format(taggable_orgs)
  end

  def taggable_coalitions(coalitions)
    taggable_orgs = coalitions.map do |coalition|
      name = sanitize(strip_tags(coalition.name))
      { id: coalition.id, name: name, value: coalition.id }
    end
    taggable_format(taggable_orgs)
  end

  def taggable_format(taggable_items)
    taggable_items.map do |item|
      item[:name] = sanitize(strip_tags(item[:name]))
      item
    end.to_json.to_s.html_safe
  end
end
