module Hub
  class OrganizationForm < Form
    include FormAttributes

    attr_accessor :organization

    set_attributes_for :organization, :name, :coalition_id, :accepts_itin_applicants, :timezone, :capacity_limit, :allows_greeters, :source_parameters_attributes
    set_attributes_for :state_routing_targets, :states
    set_attributes_for :organization_synthetic_attributes, :is_independent

    validates :name, presence: true
    validates :coalition_id, presence: true, if: -> { @is_independent != "yes" }
    validates :states, presence: true, if: -> { @is_independent == "yes" }

    def initialize(organization, params = {})
      @organization = organization
      super(params)
      normalize_is_independent
    end

    def save
      if @is_independent == "yes"
        @coalition_id = nil
      else
        @states = nil
      end
      normalize_source_parameters
      organization.assign_attributes(attributes_for(:organization))
      UpdateStateRoutingTargetsService.update(organization, (@states || "").split(","))
      organization.save
    end

    def self.from_record(record)
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(record, existing_attributes(record).slice(*attribute_keys))
    end

    private

    def normalize_is_independent
      is_independent_boolean =
        if @is_independent.nil?
          model_is_independent
        else
          @is_independent == "yes"
        end
      @is_independent = is_independent_boolean ? "yes" : "no"
    end

    def normalize_source_parameters
      @source_parameters_attributes = [] if @source_parameters_attributes.nil?
    end

    def model_is_independent
      organization.persisted? ? organization.coalition.nil? : false
    end
  end
end
