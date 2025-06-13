class EfileErrorPolicy < ApplicationPolicy
  # TODO: alternatively could just call a method like this?
  # def all_access?
  #   user.state_file_admin? || user.state_file_nj_staff? || user.admin?
  # end
  # alias index? show? update? reprocess?

  %i[index? show? update? reprocess?].each do |name|
    define_method name do
      user.state_file_admin? || user.state_file_nj_staff? || user.admin?
    end
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.state_file_admin?
        scope.where.not(service_type: "state_file_nj")
      elsif user.state_file_nj_staff?
        scope.where(service_type: "state_file_nj")
      elsif user.admin?
        scope.where(service_type: "ctc")
      end
    end
  end
end