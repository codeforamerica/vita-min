# TODO delete this

module StateFile
  class NyW2Form < QuestionsForm
    attr_accessor :w2s
    validate :validate_w2s

    def initialize(intake = nil, params = nil)
      super
      @w2s = intake.state_file_w2s
      assign_w2_params(params) unless params.nil?
    end

    def self.from_intake(intake)
      unless intake.state_file_w2s.present?
        intake.direct_file_data.w2s.each do |df_w2|
          intake.state_file_w2s.build(StateFileW2.from_df_w2(df_w2).attributes)  # TODO: Is there a way to pass in the model without saving it?
        end
      end
      new(intake)
    end

    def save
      @w2s.each(&:save!)
    end

    # assigning the @w2s variable does seem a little janky to me but i was in get-the-test-to-pass mode
    # TODO: Should we refactor this to override the assign_attributes method?
    def assign_w2_params(params)
      @w2s.each_with_index do |state_file_w2, index|
        w2_params = params.fetch("w2[#{index}]")
        # TODO: Only allow setting the ids here...
        state_file_w2.assign_attributes(w2_params)
      end
    end

    def validate_w2s
      # TODO: Check that the w2s either are new or already belong to the intake
      @w2s.each_with_index do |state_file_w2, index|
        unless state_file_w2.valid?
          state_file_w2.errors.each do |error|
            # TODO: I'm pretty sure "key" and "message" attributes are not what I actually need
            errors.add("w2[#{index}].#{error.key}", error.message)
          end
        end
      end
    end
  end
end