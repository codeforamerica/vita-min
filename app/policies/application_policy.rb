# ApplicationPolicy defines core authorization principles for your entire Rails application
# starting point for all other policy classes, offering several benefits like Default Permissions, Inheritance, Scopes and Flexibility
# The most common and generic permissions can be defined in the ApplicationPolicy.
# You can override methods in specific policies to have granular control over models or actions.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record # this is the model object
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
