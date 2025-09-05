class EfileErrorPolicy < ApplicationPolicy
  STATE_FILE_SERVICE_TYPES = Set.new(%w[state_file unfilled state_file_az state_file_ny state_file_md state_file_nc state_file_id ctc]).freeze

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.state_file_admin?
        scope.where(service_type: STATE_FILE_SERVICE_TYPES)
      elsif user.state_file_nj_staff?
        scope.where(service_type: "state_file_nj")
      elsif user.admin?
        scope.where(service_type: "ctc")
      else
        scope.none
      end
    end
  end

  def index?
    user.state_file_admin? || user.state_file_nj_staff? || user.admin?
  end

  def show? = record_exists_in_scope
  def update? = record_exists_in_scope
  def reprocess? = update?
end