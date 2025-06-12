class EfileErrorPolicy < ApplicationPolicy
  # cannot :manage, EfileError do |error|
  #   %w[state_file unfilled state_file_az state_file_ny state_file_md state_file_nc state_file_id].include?(error.service_type)
  # end # unless statefile admin
  # can :manage, EfileError, service_type: "state_file_nj" if user.state_file_nj_staff?

  def manage?
    user.state_file_admin? || user.state_file_nj_staff?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.state_file_admin?
        scope.where(service_type: %w[state_file unfilled state_file_az state_file_ny state_file_md state_file_nc state_file_id])
      else
        scope.where(service_type: "state_file_nj")
      end
    end
  end
end
