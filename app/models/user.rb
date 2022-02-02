# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  current_sign_in_at        :datetime
#  current_sign_in_ip        :string
#  email                     :citext           not null
#  encrypted_access_token    :string
#  encrypted_access_token_iv :string
#  encrypted_password        :string           default(""), not null
#  failed_attempts           :integer          default(0), not null
#  invitation_accepted_at    :datetime
#  invitation_created_at     :datetime
#  invitation_limit          :integer
#  invitation_sent_at        :datetime
#  invitation_token          :string
#  invitations_count         :integer          default(0)
#  last_sign_in_at           :datetime
#  last_sign_in_ip           :string
#  locked_at                 :datetime
#  name                      :string
#  phone_number              :string
#  reset_password_sent_at    :datetime
#  reset_password_token      :string
#  role_type                 :string           not null
#  sign_in_count             :integer          default(0), not null
#  suspended_at              :datetime
#  timezone                  :string           default("America/New_York"), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  invited_by_id             :bigint
#  role_id                   :bigint           not null
#
# Indexes
#
#  index_users_on_email                  (email) UNIQUE
#  index_users_on_invitation_token       (invitation_token) UNIQUE
#  index_users_on_invitations_count      (invitations_count)
#  index_users_on_invited_by_id          (invited_by_id)
#  index_users_on_reset_password_token   (reset_password_token) UNIQUE
#  index_users_on_role_type_and_role_id  (role_type,role_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#
class User < ApplicationRecord
  include PgSearch::Model

  devise :database_authenticatable, :lockable, :validatable, :timeoutable, :trackable, :invitable, :recoverable

  pg_search_scope :search, against: [
    :email, :id, :name, :phone_number, :role_type
  ], using: { tsearch: { prefix: true } }

  self.per_page = 25

  before_validation :format_phone_number
  validates :phone_number, e164_phone: true, allow_blank: true
  validates :email, 'valid_email_2/email': { mx: true }
  has_many :assigned_tax_returns, class_name: "TaxReturn", foreign_key: :assigned_user_id
  has_many :access_logs
  has_many :notifications, class_name: "UserNotification"
  belongs_to :role, polymorphic: true

  attr_encrypted :access_token, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }

  validates_presence_of :name
  validates_inclusion_of :timezone, in: ActiveSupport::TimeZone.country_zones("us").map { |tz| tz.tzinfo.name }

  scope :active, -> { where(suspended_at: nil) }
  scope :suspended, -> { where.not(suspended_at: nil) }

  def accessible_coalitions
    case role_type
    when AdminRole::TYPE
      Coalition.all
    when CoalitionLeadRole::TYPE
      Coalition.where(id: role.coalition)
    else
      Coalition.none
    end
  end

  def role_name
    return nil unless role_type.present?

    role_type.gsub("Role", "").underscore.humanize.titlecase
  end

  def served_entity
    role&.served_entity if role.respond_to? :served_entity
  end

  def name_with_role_and_entity
    content = "#{name_with_suspended} - #{role_name}"
    content += " - #{served_entity.name}" if served_entity.present?
    content
  end

  def name_with_suspended
    suspended? ? I18n.t("hub.suspended_user_name", name: name) : name
  end

  def accessible_vita_partners
    case role_type
    when AdminRole::TYPE, ClientSuccessRole::TYPE
      VitaPartner.all
    when OrganizationLeadRole::TYPE
      VitaPartner.organizations.where(id: role.organization).or(VitaPartner.sites.where(parent_organization: role.organization))
    when TeamMemberRole::TYPE, SiteCoordinatorRole::TYPE
      VitaPartner.sites.where(id: role.site)
    when CoalitionLeadRole::TYPE
      organizations = VitaPartner.organizations.where(coalition: role.coalition)
      sites = VitaPartner.sites.where(parent_organization: organizations)
      organizations.or(sites)
    when GreeterRole::TYPE
      VitaPartner.allows_greeters
    else
      VitaPartner.none
    end
  end

  def self.roles
    [
      AdminRole::TYPE,
      ClientSuccessRole::TYPE,
      CoalitionLeadRole::TYPE,
      GreeterRole::TYPE,
      OrganizationLeadRole::TYPE,
      SiteCoordinatorRole::TYPE,
      TeamMemberRole::TYPE
    ]
  end

  def accessible_users
    case role_type
    when AdminRole::TYPE
      User.all
    when CoalitionLeadRole::TYPE
      coalitions_leads = User.where(role: CoalitionLeadRole.where(coalition: role.coalition))
      organizations = VitaPartner.organizations.where(coalition: role.coalition)
      sites = VitaPartner.sites.where(parent_organization: organizations)
      organization_leads = User.where(role: OrganizationLeadRole.where(organization: organizations))
      site_coordinators = User.where(role: SiteCoordinatorRole.where(site: sites))
      team_members = User.where(role: TeamMemberRole.where(site: sites))
      coalitions_leads.or(organization_leads).or(site_coordinators).or(team_members)
    when OrganizationLeadRole::TYPE
      organization_leads = User.where(role: OrganizationLeadRole.where(organization: role.organization))
      sites = VitaPartner.sites.where(parent_organization: role.organization)
      site_coordinators = User.where(role: SiteCoordinatorRole.where(site: sites))
      team_members = User.where(role: TeamMemberRole.where(site: sites))
      organization_leads.or(site_coordinators).or(team_members)
    when SiteCoordinatorRole::TYPE, TeamMemberRole::TYPE
      organization_leads = User.where(role: OrganizationLeadRole.where(organization: role.site.parent_organization))
      site_coordinators = User.where(role: SiteCoordinatorRole.where(site: role.site))
      team_members = User.where(role: TeamMemberRole.where(site: role.site))
      organization_leads.or(site_coordinators).or(team_members)
    else
      User.none
    end
  end

  def self.taggable_for(client)
    users = User.where(role_type: [AdminRole::TYPE, ClientSuccessRole::TYPE, GreeterRole::TYPE])
    coalition = client.vita_partner&.coalition
    users = users.or(User.where(role: CoalitionLeadRole.where(coalition: coalition))) if coalition.present?
    users = users.or(User.where(role: OrganizationLeadRole.where(organization: client.vita_partner))) if client.vita_partner&.organization?

    if client.vita_partner&.site?
      team_members = User.where(role: TeamMemberRole.where(site: client.vita_partner))
      site_leads = User.where(role: SiteCoordinatorRole.where(site: client.vita_partner))
      org_leads = User.where(role: OrganizationLeadRole.where(organization: client.vita_partner.parent_organization))
      users = users.or(org_leads).or(site_leads).or(team_members)
    end

    users.includes(:role).order(name: :asc)
  end

  def first_name
    name&.split(" ")&.first
  end

  def start_date
    invitation_accepted_at || created_at
  end

  # Send Devise emails via job, per https://github.com/heartcombo/devise#activejob-integration
  def send_devise_notification(notification, *args)
    if Rails.env.development?
      devise_mailer.send(notification, self, *args).deliver_later
    else
      super
    end
  end

  def admin?
    role_type == AdminRole::TYPE
  end

  def greeter?
    role_type == GreeterRole::TYPE
  end

  def org_lead?
    role_type == OrganizationLeadRole::TYPE
  end

  def site_coordinator?
    role_type == SiteCoordinatorRole::TYPE
  end

  def coalition_lead?
    role_type == CoalitionLeadRole::TYPE
  end

  def suspended?
    suspended_at.present?
  end

  def active?
    !suspended?
  end

  def active_for_authentication?
    # overrides
    super && !suspended?
  end

  def suspend!
    assigned_tax_returns.update(assigned_user: nil)
    update_columns(suspended_at: DateTime.now)
  end

  def activate!
    update_columns(suspended_at: nil)
  end

  private

  def format_phone_number
    self.phone_number = PhoneParser.normalize(phone_number) if phone_number_changed?
  end
end
