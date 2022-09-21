module Ctc
  module W2s
    class MiscInfoForm < W2Form
      set_attributes_for(
        :w2,
      )

      def save
        extra_attributes = w2.completed_at.nil? ? {completed_at: DateTime.now} : {}
        @w2.assign_attributes(attributes_for(:w2).merge(extra_attributes))
        @w2.save!
      end
    end
  end
end
