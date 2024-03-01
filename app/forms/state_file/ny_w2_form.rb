module StateFile
  class NyW2Form < QuestionsForm
    validate :validate_w2s

    def initialize(intake = nil, params = nil)
      super
      assign_w2_attributes unless params.nil?
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
      assign_nested_attributes

      @w2s.each(&:save!)
    end

    # assigning the @w2s variable does seem a little janky to me but i was in get-the-test-to-pass mode
    def assign_nested_attributes
      if @intake.state_file_w2s.present?
        @intake.state_file_w2s.each do |w2|
          matching_attrs = w2s_attributes.find do |_, attrs|
            w2.w2_index == attrs[:w2_index]
          end
          w2.assign_attributes(matching_attrs[1])
        end
        @w2s = @intake.state_file_w2s
      else
        @w2s = w2s_attributes.map do |_, attrs|
          StateFileW2.new(state_file_intake: @intake, **attrs)
        end
      end
    end

    # thinking we shuold put validations on the model level (StateFileW2) and call valid on each instance
    #def valid?
    #  super
    #end

    def validate_w2s
      # TODO: Check that the w2s either are new or already belong to the intake
      intake.state_file_w2s.each_with_index do |state_file_w2, index|
        unless state_file_w2.valid?
          state_file_w2.errors.each do |error|
            #TODO: I'm pretty sure "key" and "message" attributes are not what I actually need
            errors.add("w2[#{index}].#{error.key}", error.message)
          end
        end
      end
    end
  end
end