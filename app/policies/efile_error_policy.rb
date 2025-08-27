class EfileErrorPolicy < ApplicationPolicy
  STATE_FILE_SERVICE_TYPES = Set.new(%w[state_file unfilled state_file_az state_file_ny state_file_md state_file_nc state_file_id ctc]).freeze

  # collection actions
  def index?
    self.class.permitted_service_types_for(user).any?
  end

  # member actions
  def show? = permitted_for_single_record?
  def update? = permitted_for_single_record?
  def reprocess? = update?

  class Scope < ApplicationPolicy::Scope
    # scope is used for collection actions like index or search
    def resolve
      allowed_service_types = EfileErrorPolicy.permitted_service_types_for(user)
      allowed_service_types.any? ? scope.where(service_type: allowed_service_types) : scope.none
    end
  end

  # shared auth rule
  def self.permitted_service_types_for(user)
    if user.state_file_admin?
      STATE_FILE_SERVICE_TYPES.to_a
    elsif user.state_file_nj_staff?
      %w[state_file_nj]
    elsif user.admin?
      %w[ctc]
    else
      []
    end
  end

  private

  def permitted_for_single_record?
    self.class.permitted_service_types_for(user).include?(record.service_type.to_s)
  end
end