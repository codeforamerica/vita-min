module Hub
  class OrganizationsPresenter
    attr_reader :current_ability, :organizations, :target_entries, :coalitions, :state_routing_targets

    def initialize(current_ability)
      @current_ability = current_ability
      @organizations = Organization.accessible_by(current_ability).includes(:child_sites, :organization_capacity).load
      @coalitions = Coalition.accessible_by(current_ability)
      @state_routing_targets = StateRoutingTarget.where(target: @organizations).or(StateRoutingTarget.where(target: @coalitions)).load.group_by(&:state_abbreviation)
    end

    Capacity = Struct.new(:current_count, :total_capacity) do
      def initialize(current_count = 0, total_capacity = 0)
        super
      end
    end

    def accessible_entities_for(state)
      @state_routing_targets[state]&.map do |target|
        target.target_type == "Coalition" ? coalition(target.target_id) : organization(target.target_id)
      end
    end

    # use instead of coalition.organizations in the view so that we're not loading organizations 2x
    def organizations_in_coalition(coalition)
      orgs_by_coalition_id[coalition.id] || []
    end

    def organization_capacity(organization)
      return unless current_ability.can?(:read, organization)

      Capacity.new(
        organization.organization_capacity.active_client_count || 0,
        organization.organization_capacity.capacity_limit || 0
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