module Efile
  class Relationship
    attr_reader :id, :relationship, :irs_enum

    def self.import(filename)
      @@relationships =
        YAML.load_file(filename)['relationships'].map do |relationship|
          new(relationship["id"], relationship["relationship"].to_sym, relationship["irs_enum"])
        end
    end

    def self.all
      @@relationships
    end

    def self.find(id)
      @@relationships.find { |relationship| id == relationship.id }
    end

    def initialize(id, relationship, irs_enum)
      @id = id
      relationships = [:qualifying_relative, :qualifying_child, :ineligible]
      raise "Invalid relationship. Relationship #{relationship} must be in: #{relationships}" unless relationship.in? relationships
      @relationship = relationship
      @irs_enum = irs_enum
    end

    def qualifying_child_relationship?
      relationship == :qualifying_child
    end

    def qualifying_relative_relationship?
      relationship == :qualifying_relative
    end
  end
end
