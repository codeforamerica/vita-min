module StateFile
  # This concern can be used in concert with Navigation::RepeatedMultiPageStep
  # It requires you to add a hidden `item_index` input to your edit template!
  module RepeatedQuestionConcern
    extend ActiveSupport::Concern

    included do
      attr_reader :item_index
      before_action :set_index_and_load_item
    end

    private

    def set_index_and_load_item
      @item_index = params[:item_index].present? ? params[:item_index].to_i : 0
      load_item(item_index)
    end

    def load_item(index)
      # define in controller
      raise NotImplementedError
    end
  end
end
