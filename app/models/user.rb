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

  belongs_to :organization_lead_role, -> { where(users: { role_type: 'OrganizationLeadRole' }) }, foreign_key: 'role_id', optional: true

  attr_encrypted :access_token, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }

  validates_presence_of :name
  validates_inclusion_of :timezone, in: ActiveSupport::TimeZone.country_zones("us").map { |tz| tz.tzinfo.name }

  scope :active, -> { where(suspended_at: nil) }

  def accessible_coalitions
    case role_type
    when AdminRole::TYPE
      Coalition.all
    when CoalitionLeadRole::TYPE
      Coalition.where(id: role.coalition)
    when GreeterRole::TYPE
      role.coalitions
    else
      Coalition.none
    end
  end

  def accessible_vita_partners
    case role_type
    when AdminRole::TYPE
      VitaPartner.all
    when OrganizationLeadRole::TYPE
      VitaPartner.organizations.where(id: role.organization).or(
        VitaPartner.sites.where(parent_organization_id: role.organization)
      )
    when TeamMemberRole::TYPE, SiteCoordinatorRole::TYPE
      VitaPartner.sites.where(id: role.site)
    when CoalitionLeadRole::TYPE
      organizations = VitaPartner.organizations.where(coalition: role.coalition)
      sites = VitaPartner.sites.where(parent_organization: organizations)
      organizations.or(sites)
    when GreeterRole::TYPE
      direct_organizations = VitaPartner.organizations.where(id: role.organizations)
      child_organizations = VitaPartner.where(coalition: role.coalitions)
      organizations = direct_organizations.or(child_organizations)
      sites = VitaPartner.sites.where(parent_organization: organizations)
      organizations.or(sites)
    else
      VitaPartner.none
    end
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
      site_coordinators = User.where(role: SiteCoordinatorRole.where(site: role.site))
      team_members = User.where(role: TeamMemberRole.where(site: role.site))
      site_coordinators.or(team_members)
    else
      User.none
    end
  end

  def first_name
    name&.split(" ")&.first
  end

  def start_date
    invitation_accepted_at || created_at
  end

  def format_phone_number
    self.phone_number = PhoneParser.normalize(phone_number) if phone_number_changed?
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

  def suspended?
    suspended_at.present?
  end

  def active_for_authentication?
    # overrides
    super && !suspended?
  end
end
