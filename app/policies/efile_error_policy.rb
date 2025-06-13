class EfileErrorPolicy < ApplicationPolicy
  %i[index? show? update?].each do |name|
    define_method name do
      user.state_file_admin? || user.state_file_nj_staff? || user.admin?
    end
  end

  def reprocess?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    STATE_FILE_SERVICE_TYPES = %w[state_file unfilled state_file_az state_file_ny state_file_md state_file_nc state_file_id ctc].freeze

    def resolve
      if user.state_file_admin?
        scope.where(service_type: STATE_FILE_SERVICE_TYPES)
      elsif user.state_file_nj_staff?
        scope.where(service_type: "state_file_nj")
      elsif user.admin?
        scope.where(service_type: "ctc")
      else
        EfileError.none
      end
    end
  end
end