module StateFile
  module ArchivedIntakes
    class VerificationCodeController < ApplicationController
      def edit
        @form = VerificationCodeForm.new
      end

    end
  end
end
