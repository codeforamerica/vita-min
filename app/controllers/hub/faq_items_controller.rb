module Hub
  class FaqItemsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :require_admin
    load_and_authorize_resource
    layout "hub"

    def new; end

    def create
      @faq_item = FaqItem.new(faq_item_params)

      if @faq_item.save
        flash_message = "Successfully created '#{@faq_item.question_en}'"
        render :show, notice: flash_message
      else
        flash_message = "Unable to create '#{@faq_item.question_en}', check validations"
        render :new, error: flash_message
      end
    end

    def edit; end

    def update
      if @faq_item.update(faq_item_params)
        flash_message = "Successfully updated '#{@faq_item.question_en}'"
        render :show, notice: flash_message
      else
        flash_message = "Unable to update '#{@faq_item.question_en}', check validations"
        render :edit, error: flash_message
      end
    end

    def show; end

    private

    def faq_item_params
      params.require(:faq_item).permit(:answer_en, :answer_es, :position, :question_en, :question_es, :slug, :faq_category_id)
    end

    def category_name_pairs
      @category_name_pairs ||= FaqCategory.all.map{ |cat| [cat.name_en, cat.id] }
    end
  end
end
