# == Schema Information
#
# Table name: users
#
#  id                             :bigint           not null, primary key
#  current_sign_in_at             :datetime
#  current_sign_in_ip             :string
#  email                          :citext           not null
#  encrypted_password             :string           default(""), not null
#  external_provider              :string
#  external_uid                   :string
#  failed_attempts                :integer          default(0), not null
#  high_quality_password_as_of    :datetime
#  invitation_accepted_at         :datetime
#  invitation_created_at          :datetime
#  invitation_limit               :integer
#  invitation_sent_at             :datetime
#  invitation_token               :string
#  invitations_count              :integer          default(0)
#  last_sign_in_at                :datetime
#  last_sign_in_ip                :string
#  locked_at                      :datetime
#  name                           :string
#  phone_number                   :string
#  reset_password_sent_at         :datetime
#  reset_password_token           :string
#  role_type                      :string           not null
#  should_enforce_strong_password :boolean          default(FALSE), not null
#  sign_in_count                  :integer          default(0), not null
#  suspended_at                   :datetime
#  timezone                       :string           default("America/New_York"), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  invited_by_id                  :bigint
#  role_id                        :bigint           not null
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
  devise :database_authenticatable, :lockable, :timeoutable, :trackable, :invitable, :recoverable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  pg_search_scope :search, against: [
    :email, :id, :name, :phone_number, :role_type
  ], using: { tsearch: { prefix: true } }

  self.per_page = 50

  before_validation :format_phone_number
  validates :phone_number, e164_phone: true, allow_blank: true

  validates_presence_of :email
  validates_uniqueness_of :email, allow_blank: true, case_sensitive: true, if: :will_save_change_to_email?

  validates :email, 'valid_email_2/email': { mx: true }
  validates_length_of :password, maximum: Devise.password_length.end, allow_blank: true
  validates :password, password_strength: true
  validates_confirmation_of :password, message: -> (_object, _data) { I18n.t("errors.attributes.password.not_matching") }
  validates_presence_of :password, if: -> (r) { !r.persisted? || !r.password.nil? || !r.password_confirmation.nil? }

  has_many :assigned_tax_returns, class_name: "TaxReturn", foreign_key: :assigned_user_id
  has_many :access_logs
  has_many :notifications, class_name: "UserNotification"
  belongs_to :role, polymorphic: true

  validates_presence_of :name
  validates_inclusion_of :timezone, in: ActiveSupport::TimeZone.country_zones("us").map { |tz| tz.tzinfo.name }

  scope :active, -> { where(suspended_at: nil) }
  scope :suspended, -> { where.not(suspended_at: nil) }

  def valid?(*_args)
    [super, role&.valid?].all?
  end

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

  def served_entities
    role&.served_entities if role.respond_to? :served_entities
  end

  def name_with_role
    "#{name_with_suspended} (#{role_name})"
  end

  def name_with_role_and_entity
    content = name_with_role
    content += " - #{served_entities.first.name}" if served_entities&.any?
    content += " (and #{served_entities.count - 1} more)" if (served_entities&.count || 0) > 1
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
      VitaPartner.sites.where(id: role.sites)
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
      StateFileNjStaffRole::TYPE,
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
      site_coordinators = User.where(role: SiteCoordinatorRole.assignable_to_sites(sites))
      team_members = User.where(role: TeamMemberRole.assignable_to_sites(sites))
      coalitions_leads.or(organization_leads).or(site_coordinators).or(team_members)
    when OrganizationLeadRole::TYPE
      organization_leads = User.where(role: OrganizationLeadRole.where(organization: role.organization))
      sites = VitaPartner.sites.where(parent_organization: role.organization)
      site_coordinators = User.where(role: SiteCoordinatorRole.assignable_to_sites(sites))
      team_members = User.where(role: TeamMemberRole.assignable_to_sites(sites))
      organization_leads.or(site_coordinators).or(team_members)
    when SiteCoordinatorRole::TYPE, TeamMemberRole::TYPE
      organization_leads = User.where(role: OrganizationLeadRole.where(organization: role.sites.map(&:parent_organization)))
      site_coordinators = User.where(role: SiteCoordinatorRole.assignable_to_sites(role.sites))
      team_members = User.where(role: TeamMemberRole.assignable_to_sites(role.sites))
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
      team_members = User.where(role: TeamMemberRole.assignable_to_sites([client.vita_partner]))
      site_leads = User.where(role: SiteCoordinatorRole.assignable_to_sites([client.vita_partner]))
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

  def client_success?
    role_type == ClientSuccessRole::TYPE
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

  def state_file_nj_staff?
    role_type == StateFileNjStaffRole::TYPE
  end

  def state_file_admin?
    role_type == AdminRole::TYPE && role.state_file?
  end

  def team_member?
    role_type == TeamMemberRole::TYPE
  end

  def suspended?
    suspended_at.present?
  end

  def active?
    !suspended?
  end

  def has_lead_dashboard_access?
    site_coordinator? || coalition_lead? || org_lead? || admin?
  end

  def has_non_lead_dashboard_access?
    team_member?
  end

  def has_dashboard_access?
    has_lead_dashboard_access? || has_non_lead_dashboard_access?
  end

  # Takes either a singular role symbol or an enumerable of role symbols and
  # checks if the user has any of those roles.
  #
  # @param roles [Enumerable, Symbol] A role as a symbol or enumerable of
  #   symbols that represent the role or roles being checked for
  # @return [Boolean] Whether the user is a member of any of the roles
  def role?(roles)
    roles = [roles] unless roles.is_a?(Enumerable)

    roles.map do |role|
      case role
      when :client_success
        client_success?
      when :admin
        admin?
      when :greeter
        greeter?
      when :org_lead
        org_lead?
      when :site_coordinator
        site_coordinator?
      when :coalition_lead
        coalition_lead?
      when :state_file_nj_staff
        state_file_nj_staff?
      when :state_file_admin
        state_file_admin?
      when :team_member
        team_member?
      else
        false
      end
    end.any?
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

  def self.google_login_domain?(email)
    email = email.downcase
    email_host = email.include?('@') ? email.split("@")[-1] : email
    Devise.omniauth_configs[:google_oauth2].options[:hd].include?(email_host)
  end

  def self.from_omniauth(auth_hash)
    oauth2_provider_name = "google_oauth2"
    return nil unless Rails.configuration.google_login_enabled
    return nil unless auth_hash['provider'] == oauth2_provider_name

    email = auth_hash.info['email']
    return nil unless google_login_domain?(email) && google_login_domain?(auth_hash.extra.id_info["hd"])

    matching_users = User.where(email: email, external_provider: [nil, oauth2_provider_name], external_uid: [nil, auth_hash['uid']], suspended_at: nil)
    # NOTE: Duplicate emails should never happen because there is a `validates_uniqueness_of` email constraint
    #   However, I wanted to preserve the previous implementation as closely as possible, which means prioritizing
    #   returning a user account with AdminRole, if one exists
    user = matching_users.where(role_type: "AdminRole").first || matching_users.first
    user.update!(external_provider: oauth2_provider_name, external_uid: auth_hash['uid']) if user.present? && user.external_uid.nil?
    user
  end

  private

  def format_phone_number
    self.phone_number = PhoneParser.normalize(phone_number) if phone_number_changed?
  end
end
