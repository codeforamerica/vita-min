module Hub
  class OrganizationForm < Form
    include FormAttributes

    attr_accessor :organization

    set_attributes_for :organization, :name, :coalition_id, :timezone, :capacity_limit, :allows_greeters
    set_attributes_for :state_routing_targets, :states
    set_attributes_for :organization_synthetic_attributes, :is_independent

    def initialize(organization, params = {})
      @organization = organization
      super(params)
      @is_independent = @is_independent.nil? ? model_is_independent : @is_independent
    end

    def save
      organization.assign_attributes(attributes_for(:organization))
      organization.save
    end

    private

    def model_is_independent
      organization.persisted? ? organization.coalition.nil? : false
    end
  end
end
