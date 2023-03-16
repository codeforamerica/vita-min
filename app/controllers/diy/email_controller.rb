module Diy
  class EmailController < BaseController
    def edit
      redirect_to(diy_continue_to_fsa_path)
    end

    def update
      redirect_to(diy_continue_to_fsa_path)
    end
  end
end
