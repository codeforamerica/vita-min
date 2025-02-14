module Hub
  class OrganizationsPresenter
    # load and authorize? except if org lead
    attr_reader :current_ability, :organizations, :target_entries, :coalitions, :state_routing_targets, :state_routing_targets_for_orgs_under_coalitions

    def initialize(current_ability)
      @current_ability = current_ability
      accessible_organizations = Organization.accessible_by(current_ability)
      @organizations = accessible_organizations.includes(:child_sites).with_computed_client_count.load
      @coalitions = Coalition.accessible_by(current_ability)
      coalition_parents_of_dependent_orgs = accessible_organizations.where.not(coalition_id: nil).pluck(:coalition_id)
      #srts for independent orgs, dependent orgs and coalitions
      @state_routing_targets_of_parent_coalition = StateRoutingTarget.where(target_id: coalition_parents_of_dependent_orgs).load.group_by(&:state_abbreviation)
      @state_routing_targets = StateRoutingTarget.where(target: accessible_organizations).or(StateRoutingTarget.where(target: @coalitions)).load.group_by(&:state_abbreviation)
      binding.pry
    end

    Capacity = Struct.new(:current_count, :total_capacity) do
      def initialize(current_count = 0, total_capacity = 0)
        super
      end
    end

    # i want an array of coalitions and orgs organized by state
    # state => coalitions and orgs
    # can we just do all the authorization stuff at the end?

    def accessible_entities_for(state)
      # need to return the vita partners by the state they are under
      accessible_entities = @state_routing_targets[state]&.map do |target|
        # if SRT is connected to coalition then grab coalition
        # but if is a user that can't see coalitions then we need to grab their
        # @presenter.organizations.where.not(coalition_id: nil)
        target.target_type == "Coalition" ? coalition(target.target_id) : organization(target.target_id)
      end

      if @coalitions.empty? && @organizations.present?
        # then check that parent coalition doesn't have SRT in state
        @state_routing_targets_of_parent_coalition[state]&.map do |target|
          if target.target_type == "Coalition"
            target.organizations.each do |org|
              accessible_entities << org if organization(org.id)
            end
          elsif target.target_type == "Organization"
            accessible_entities << organization(target.target_id)
          end
        end
      end

      return accessible_entities
    end

    # use instead of coalition.organizations in the view so that we're not loading organizations 2x
    def organizations_in_coalition(coalition)
      orgs_by_coalition_id[coalition.id] || []
    end

    def organization_capacity(organization)
      return unless current_ability.can?(:read, organization)

      organization = organization(organization.id)
      Capacity.new(
        organization.active_client_count || 0,
        organization.capacity_limit || 0
      )
    end

    def coalition_capacity(coalition)
      return unless current_ability.can?(:read, coalition)

      capacity = Capacity.new
      orgs_by_coalition_id[coalition.id]&.each do |target|
        target_capacity = organization_capacity(target)
        capacity.current_count += target_capacity.current_count
        capacity.total_capacity += target_capacity.total_capacity
      end
      capacity
    end

    def state_capacity(state)
      capacity = Capacity.new
      accessible_entities_for(state)&.each do |entity|
        target_capacity = entity.is_a?(Coalition) ? coalition_capacity(entity) : organization_capacity(entity)
        capacity.current_count += target_capacity.current_count
        capacity.total_capacity += target_capacity.total_capacity
      end
      capacity
    end

    def unrouted_organizations
      organizations.where.missing(:state_routing_targets)
    end

    def unrouted_coalitions
      coalitions.where.missing(:state_routing_targets)
    end

    private

    def orgs_by_coalition_id
      @orgs_by_coalition_id ||= organizations.group_by(&:coalition_id)
    end

    def organization(organization_id)
      organizations.find { |organization| organization.id == organization_id }
    end

    def coalition(coalition_id)
      coalitions.find { |coalition| coalition.id == coalition_id }
    end
  end
end