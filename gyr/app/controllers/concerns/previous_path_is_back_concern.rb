module PreviousPathIsBackConcern
  extend ActiveSupport::Concern

  private

  def prev_path
    :back
  end
end
