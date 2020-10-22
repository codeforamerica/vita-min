# Access Control Data Model

Date: 2020-10-20 (but written and revised multiple times before this date)
Authors: Ben Golder, Shannon Byrne, Sarah Niemeyer, reviewed by Engineering team

## Assumptions based on research so far

1. There is no need for a volunteer to belong to multiple organizations or partners at the same time.
2. Access to a client's info has a few consistent rules: the client has been assigned to the user's organization (or sub-organization in the case of coalitions) or the user has an extra-privileged role.
3. Assigning a client to a user means something different than assigning a client to an organization. Assigning a Client to an organization grants access to members of that organization. Assigning to an individual user signals responsibility for who will to do the tax prep. We would never assign a client to a user who is not in the assigned organization.

## Roles

VITA has a well-understood small number of roles that don't change over the course of the year. These roles are not organization-specific. Some are defined by the IRS and have certification processes.
One user can have one or more roles.
Since the set of roles won't change very much, we don't need to store that information as a model of any sort, and the relationship between users and roles can be very simple: a user does or does not have a certain role.

```ruby
class User
  belongs_to :organization

  has_many :supported_organizations

  is_greeter
  is_client_support
  is_volunteer
  is_quality_reviewer
  is_site_coordinator
  is_site_owner
  is_admin
  ...
end
```

### Scope access control to organizations

Since some roles are scoped to the application (super_admin) and others are scoped to an organization OR supported organization, looking up roles in the context of a specific organization can help make sure we're getting the most accurate role.

```ruby
class User
  def role_for(organization)
    return :super_admin if user.is_super_admin?

    if user.organization_id == organization.id || user.organization.child_organizations.where(id: client.organization_id).exists?
      return :site_coordinator if user.is_site_coordinator?
      return :volunteer if user.is_volunteer?
    end

    if (user.is_greeter? || user.is_client_support? && user.supported_organizatons.where(id: client.organization_id).exists?) ||
        # check if the user is a greeter for a coalition
        user.supported_organizations.joins(:child_organizations).where(child_organizations: {id: client.organization}).exists?
      return :greeter if user.is_greeter?
      return :client_support if user.is_client_support?
    end
  end

  def can_access?(client)
    user.role_for(client.organization).present?
  end
end
```

## Organizations & Coalitions

All Organizations can have multiple users and clients.

Coalitions are organizations that are able to add one or more "subcontractor" organizations.
Users at a coalition are able to access the clients assigned to the subcontractors.
So far, we've only seen a need to support coaltions that are one level deep (coalition "lead" + subcontractors), but no need to support multilevel coalitions ("subsubcontractors").

```ruby
class Organization
  has_many :users
  has_many :clients

  is_coalition? # true/false
  has_many :subcontractors

  belongs_to :coalition, optional: true

  validates :no_subsubcontractors!
end
```



### Check if one user can access one client
This would be run often, and will return true in the majority of cases. We should try to return true without having to run additional queries if possible, and should order the queries from simplest and most frequent to most complicated and rarest.


```ruby
class User
  def can_access?(client)
    # if user is highly privileged, return true
    user.is_super_admin? ||
      # if client is assigned to user's org, return true
      user.organization_id == client.organization_id ||
      # check for coalition child org assignment
      user.organization.subcontractors.where(id: client.organization_id).exists? ||
      # check for greeter assistance
      (user.is_greeter? || user.is_client_support? && user.supported_organizatons.where(id: client.organization_id).exists?) ||
      # check if the user is a greeter for a coalition
      user.supported_organizations.joins(:child_organizations).where(child_organizations: {id: client.organization}).exists?
  end
end
```
This logic is best implemented via CanCanCan abilities.

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Client if user.is_super_admin?
    can :manage, Client, organization: user.organization
    # coalition
    can :manage, Client, organization: { coalition_parent: { id: user.organization_id } }
    if user.is_greeter? || user.is_client_support?
      # basic greeter or client support check
      can :manage, Client, organization_id: user.supported_organizations
      # greeter supporting a coalition parent
      can :manage, Client, organization: { coalition_parent_id: user.supported_organizations }
    end

    if user.is_site_coordinator?
      can :manage, User, organization: user.organization
    end

    if user.is_coalition_owner?
      can :manage, Organization, coalition_parent_id: user.organization_id
    end
  end
end
```


### Get a list of clients accessible to a user

This will be run often to determine which clients might show up in different list views.
Some optimization is helpful here.
It will need to be combined with other query clauses, such as filtering clients or pagination.
CanCanCan can use the Ability class to derive these scopes.

```ruby
class User
  def accessible_clients
    return Client.all if is_admin?

    query = Client.where(organization: organization)
    query = query.or(Client.where(organization: organization.child_organizations)) if is_coalition_user?
    query = query.or(Client.where(organization: organization.greeter_organizations)) if is_greeter?
    query = query.or(Client.where(organization: organization.greeter_organizations.joins(:child_organizations))) if is_greeter?

    query
  end
end
```

### Get a list of users who can access a client

```ruby
class Client
  def users_with_access
    admin_users = User.where(is_admin: true)
    users_at_assigned_organizations = User.where(organization: organization)
    users_at_coalition_parent = User.where(organization: organization.parent_organization)
    greeters_for_assigned_organization = User.joins(:greeter_organizations).where(greeter_organizations: {id: organization})
    users = admin_users.or(users_at_assigned_organizations).or(greeters_for_assigned_organization)
    users = users.or(users_at_coalition_parent) if organization.has_parent?
    users
  end
end
```


## Query Examples

### Get all the users who have a particular role at an organization

```ruby
class User
  scope :quality_reviewers, -> { where is_quality_reviewer: true }

end

class Organization
  delegate :quality_reviewers, to: :users
  # has_many :members, ?
end
```

