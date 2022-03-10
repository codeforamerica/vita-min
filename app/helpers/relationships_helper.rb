module RelationshipsHelper
  # provides a list of relationship options for dependents, and pushes the client's provided free-form answer
  # to the list if necessary.
  def dependent_relationship_options(current_relationship: nil)
    options = Efile::Relationship.all.map { |relationship| [I18n.t("general.dependent_relationships.#{relationship.id}"), relationship.id] }
    if current_relationship.present? && Efile::Relationship.find(current_relationship.to_sym).nil?
      options.push(["#{I18n.t("general.dependent_relationships.other_freefill")}: #{current_relationship}", current_relationship])
    end
    options
  end

  def relationship_label(relationship)
    return nil if relationship.nil?

    I18n.t("general.dependent_relationships.#{relationship}", default: relationship)
  end
end
