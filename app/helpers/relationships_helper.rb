module RelationshipsHelper
  # provides a list of relationship options for dependents, and pushes the client's provided free-form answer
  # to the list if necessary.
  def dependent_relationship_options(current_relationship = nil)
    options = I18n.t("general.dependent_relationships").map { |k, v| [v, k] }
    if current_relationship.present?
      key = I18n.t("general.dependent_relationships")[current_relationship.to_sym]
      options.push(["#{I18n.t("general.dependent_relationships.other")}: #{current_relationship}", current_relationship]) unless key.present?
    end
    options
  end

  def translated_relationship(relationship)
    I18n.t("general.dependent_relationships.#{relationship}", default: relationship)
  end
end