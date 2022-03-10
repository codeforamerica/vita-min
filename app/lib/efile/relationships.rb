module Efile
  class Relationships
    RELATIONSHIPS = %w[qualifying_relative qualifying_child ineligible].freeze
    @@relationships ||= IceNine.deep_freeze!(
      (YAML.load_file(Rails.root.join("app/lib/efile/relationships.yml"))['relationships']).to_h do |relationship|
        raise "Invalid relationship. Must be in: #{RELATIONSHIPS}" unless relationship["relationship"].in? RELATIONSHIPS

        [relationship["value"].to_sym, {
            relationship: relationship["relationship"].to_sym,
            irs_enum: relationship["irs_enum"]
        }]
      end
    )

    def self.relationships
      @@relationships
    end

    def initialize(relationship)
      @relationship = relationship.to_sym
      @relationship_data = @@relationships[@relationship]
      raise "Relationship not defined" unless @relationship_data.present?
    end

    def value
      @relationship
    end

    def qualifying_child_relationship?
      @relationship_data[:relationship] == :qualifying_child
    end

    def qualifying_relative_relationship?
      @relationship_data[:relationship] == :qualifying_relative
    end

    def irs_enum
      @relationship_data[:irs_enum]
    end
  end
end