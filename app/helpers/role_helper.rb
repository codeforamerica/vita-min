module RoleHelper
  def user_role_name(user)
    role_name_from_role_type(user.role_type)
  end

  def role_name_from_role_type(role_type)
    @_role_names_for_role_type ||= {}
    @_role_names_for_role_type[I18n.locale] ||= {}
    if @_role_names_for_role_type[I18n.locale][role_type]
      return @_role_names_for_role_type[I18n.locale][role_type]
    end

    result = case role_type
    when AdminRole::TYPE
      I18n.t("general.admin")
    when OrganizationLeadRole::TYPE
      I18n.t("general.organization_lead")
    when CoalitionLeadRole::TYPE
      I18n.t("general.coalition_lead")
    when SiteCoordinatorRole::TYPE
      I18n.t("general.site_coordinator")
    when ClientSuccessRole::TYPE
      I18n.t("general.client_success")
    when GreeterRole::TYPE
      I18n.t("general.greeter")
    when TeamMemberRole::TYPE
      I18n.t("general.team_member")
    end&.titleize

    @_role_names_for_role_type[I18n.locale][role_type] = result
  end

  def role_from_params(role_string, params)
    case role_string
    when OrganizationLeadRole::TYPE
      role_params = params[:organization].present? ? {organization: @vita_partners.find(JSON.parse(params[:organization].presence || '[]').pluck('id').first)} : {}
      OrganizationLeadRole.new(role_params)
    when CoalitionLeadRole::TYPE
      role_params = params[:coalition].present? ? {coalition: @coalitions.find(JSON.parse(params[:coalition].presence || '[]').pluck('id').first)} : {}
      CoalitionLeadRole.new(role_params)
    when AdminRole::TYPE
      AdminRole.new
    when SiteCoordinatorRole::TYPE
      SiteCoordinatorRole.new(sites: @vita_partners.sites.where(id: JSON.parse(params[:sites].presence || '[]').pluck('id')))
    when ClientSuccessRole::TYPE
      ClientSuccessRole.new
    when GreeterRole::TYPE
      GreeterRole.new
    when TeamMemberRole::TYPE
      TeamMemberRole.new(sites: @vita_partners.sites.where(id: JSON.parse(params[:sites].presence || '[]').pluck('id')))
    end
  end

  def taggable_items_from_role_type(role_type)
    case role_type
    when CoalitionLeadRole::TYPE
      taggable_coalitions(@coalitions)
    when OrganizationLeadRole::TYPE
      taggable_organizations(@vita_partners)
    when SiteCoordinatorRole::TYPE, TeamMemberRole::TYPE
      taggable_sites(@vita_partners)
    else
      []
    end
  end

  def role_type_from_role_name(role_name)
    return nil unless role_name.present?

    role_name = role_name.capitalize
    if role_name.include?(I18n.t("general.admin"))
      AdminRole::TYPE
    elsif role_name.include?(I18n.t("general.organization_lead")) || role_name.include?("org lead")
      OrganizationLeadRole::TYPE
    elsif role_name.include?(I18n.t("general.coalition_lead"))
      CoalitionLeadRole::TYPE
    elsif role_name.include?(I18n.t("general.site_coordinator"))
      SiteCoordinatorRole::TYPE
    elsif role_name.include?(I18n.t("general.client_success"))
      ClientSuccessRole::TYPE
    elsif role_name.include?(I18n.t("general.greeter"))
      GreeterRole::TYPE
    elsif role_name.include?(I18n.t("general.team_member"))
      TeamMemberRole::TYPE
    end
  end

  def user_group(user)
    return if user.role.nil?

    if user.role_type == OrganizationLeadRole::TYPE
      user.role.organization.name
    elsif user.role_type == CoalitionLeadRole::TYPE
      user.role.coalition.name
    elsif user.role_type == SiteCoordinatorRole::TYPE || user.role_type == TeamMemberRole::TYPE
      user.role.sites.map(&:name).join(", ")
    end
  end
end
