module Diy
  class PersonalInfoController < DiyController
    def current_diy_intake
      super || DiyIntake.new
    end

    def illustration_path; end

    def self.form_name
      "diy_personal_info_form"
    end

    #TODO: remove this when next page is added
    def next_path(params = nil)
      root_path
    end
  end
end
