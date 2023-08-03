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

    taggable_vita_partners.to_json.to_s.html_safe
  end

  def taggable_sites(vita_partners)
    vita_partners.sites.includes(:parent_organization).map do |site|
      { id: site.id, name: site.name, parentName: site.parent_organization.name, value: site.id }
    end.to_json.to_s.html_safe
  end

  def taggable_states(state_abbreviations)
    state_abbreviations.map { |abbreviation| { value: abbreviation, name: States.name_for_key(abbreviation)} }.to_json.html_safe
  end

  def taggable_independent_organizations(organizations)
    taggable_orgs = []
    organizations.each do |vita_partner|
      taggable_orgs << { id: vita_partner.id, name: vita_partner.name, value: vita_partner.id }
    end
    taggable_orgs.to_json.to_s.html_safe
  end

  def taggable_organizations(vita_partners)
    taggable_orgs = []
    Organization.where(id: vita_partners.organizations).each do |vita_partner|
      taggable_orgs << { id: vita_partner.id, name: vita_partner.name, value: vita_partner.id }
    end
    taggable_orgs.to_json.to_s.html_safe
  end

  def taggable_coalitions(coalitions)
    coalitions.map do |coalition|
      { id: coalition.id, name: coalition.name, value: coalition.id }
    end.to_json.to_s.html_safe
  end
end
