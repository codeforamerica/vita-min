module RelationshipsHelper
  # provides a list of relationship options for dependents, and pushes the client's provided free-form answer
  # to the list if necessary.
  def dependent_relationship_options(current_relationship: nil, is_ctc: false)
    allowed_types = is_ctc ? [:ctc] : [:default]
    relationships_hash = Hash[sorted_relationships(types: allowed_types)]
    options = relationships_hash.map { |k, v| [v, k] }
    if current_relationship.present?
      key = relationships_hash[current_relationship.to_sym]
      options.push(["#{I18n.t("general.dependent_relationships.other")}: #{current_relationship}", current_relationship]) unless key.present?
    end
    options
  end

  def translated_relationship(relationship)
    Hash[sorted_relationships(types: [:ctc, :default])][relationship.to_sym] || relationship
  end

  private

  def sorted_relationships(types:)
    yaml_relationships = {}
    yaml_relationships.merge!(I18n.t("general.dependent_relationships")) if types.include?(:default)
    yaml_relationships.merge!(I18n.t("general.ctc_dependent_relationships")) if types.include?(:ctc)

    yaml_relationships.map { |k, v| [k.to_s.sub(/^\d+_/, '').to_sym, v] }
  end
end
