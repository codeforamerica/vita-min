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
      puts(params.to_json)
      @is_independent = @is_independent.nil? ? model_is_independent : @is_independent
    end

    def save
      puts("first @is_independent=#{@is_independent}")
      if @is_independent
        @coalition_id = nil
      else
        @states = ""
      end
      organization.assign_attributes(attributes_for(:organization))
      UpdateStateRoutingTargetsService.update(organization, @states)
      binding.pry
      organization.save
    end

    def self.from_record(record)
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(record, existing_attributes(record).slice(*attribute_keys))
    end

    private

    def model_is_independent
      organization.persisted? ? organization.coalition.nil? : false
    end
  end
end
