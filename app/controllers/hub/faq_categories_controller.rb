module Hub
  class FaqCategoriesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :require_admin
    before_action :set_paper_trail_whodunnit
    load_and_authorize_resource
    layout "hub"

    def index
      @faq_categories = @faq_categories.order(position: :asc)
    end

    def edit
      @position_options = (1..FaqCategory.all.count).to_a
    end

    def show; end

    def new
      @position_options = (1..(FaqCategory.all.count + 1)).to_a
    end

    def create
      slug = faq_category_params[:name_en].parameterize(separator: '_')
      @faq_category = FaqCategory.new(faq_category_params.merge(slug: slug))

      if @faq_category.save
        flash_message = "Successfully created '#{@faq_category.name_en}' category"
        redirect_to hub_faq_categories_path, notice: flash_message
      else
        flash_message = "Unable to create '#{@faq_category.name_en}' category, check validations"
        render :new, error: flash_message
      end
    end

    def update
      params = if faq_category_params[:slug].present?
                 faq_category_params
               else
                 faq_category_params.merge(slug: faq_category_params[:name_en].parameterize(separator: '_'))
               end
      if @faq_category.update(params)
        flash_message = "Successfully updated '#{@faq_category.name_en}' category"
        redirect_to hub_faq_categories_path, notice: flash_message
      else
        flash_message = "Unable to update '#{@faq_category.name_en}' category, check validations"
        render :edit, error: flash_message
      end
    end

    def destroy
      begin
        ActiveRecord::Base.transaction do
          # if faq_items deletion fails, don't destroy their faq_category
          @faq_category.faq_items.map(&:destroy)
          @faq_category.destroy!
        end
        flash_message = "Deleted '#{@faq_category.name_en}' category and associated items"
      rescue ActiveRecord::InvalidForeignKey
        flash_message = "Unable to delete '#{@faq_category.name_en}' category and associated items"
      end
      redirect_to hub_faq_categories_path, notice: flash_message
    end

    private

    def faq_category_params
      params.require(:faq_category).permit(:name_en, :name_es, :position, :slug)
    end

  end
end