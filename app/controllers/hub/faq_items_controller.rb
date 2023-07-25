module Hub
  class FaqItemsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :require_admin
    before_action :set_paper_trail_whodunnit
    before_action :load_faq_category, only: [:new, :edit, :create, :show]
    load_and_authorize_resource
    layout "hub"

    def new
      faq_items = @faq_category.faq_items
      @position_options = faq_items ? (1..(faq_items.count+1)).to_a : [1]
    end

    def create
      slug = faq_item_params[:question_en].parameterize(separator: '_')
      @faq_item = FaqItem.new(faq_item_params.merge(slug: slug, faq_category: @faq_category))

      if @faq_item.save
        flash_message = "Successfully created '#{@faq_item.question_en}'"
        render :show, notice: flash_message
      else
        flash_message = "Unable to create '#{@faq_item.question_en}'"
        render :new, error: flash_message
      end
    end

    def edit
      @position_options = @faq_category.faq_items.pluck(:position)
    end

    def update
      params = if faq_item_params[:slug].present?
                 faq_item_params
               else
                 faq_item_params.merge(slug: faq_item_params[:question_en].parameterize(separator: '_'))
               end

      if @faq_item.update(params)
        flash_message = "Successfully updated '#{@faq_item.question_en}'"
        render :show, notice: flash_message
      else
        flash_message = "Unable to update '#{@faq_item.question_en}'"
        render :edit, error: flash_message
      end
    end

    def show; end

    def destroy
      begin
        ActiveRecord::Base.transaction do
          @faq_item.destroy!
        end
        flash[:notice] = "Deleted '#{@faq_item.question_en}'"
      rescue ActiveRecord::InvalidForeignKey
        flash[:error] = "Unable to delete '#{@faq_item.question_en}'"
      end
      redirect_to hub_faq_categories_path
    end

    private

    def faq_item_params
      params.require(:faq_item).permit(:answer_en, :answer_es, :position, :question_en, :question_es, :slug, :faq_category_id)
    end

    def load_faq_category
      @faq_category = FaqCategory.find(params[:faq_category_id])
    end
  end
end
