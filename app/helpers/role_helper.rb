module RoleHelper
  def user_role(user)
    readable_role_from_role_type(user.role_type)
  end

  def readable_role_from_role_type(role_type)
    case role_type
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
  end

  def role_type_from_readable_role(readable_role)
    return nil unless readable_role.present?

    readable_role = readable_role&.capitalize
    if readable_role.include? I18n.t("general.admin")
      AdminRole::TYPE
    elsif readable_role.include? I18n.t("general.organization_lead")
      OrganizationLeadRole::TYPE
    elsif readable_role.include? I18n.t("general.coalition_lead")
      CoalitionLeadRole::TYPE
    elsif readable_role.include? I18n.t("general.site_coordinator")
      SiteCoordinatorRole::TYPE
    elsif readable_role.include? I18n.t("general.client_success")
      ClientSuccessRole::TYPE
    elsif readable_role.include? I18n.t("general.greeter")
      GreeterRole::TYPE
    elsif readable_role.include? I18n.t("general.team_member")
      TeamMemberRole::TYPE
    else
      false
    end
  end

  def user_group(user)
    if user.role_type == OrganizationLeadRole::TYPE
      user.role.organization.name
    elsif user.role_type == CoalitionLeadRole::TYPE
      user.role.coalition.name
    elsif user.role_type == SiteCoordinatorRole::TYPE || user.role_type == TeamMemberRole::TYPE
      user.role.site.name
    end
  end
end
