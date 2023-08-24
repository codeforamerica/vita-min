class BasePresenter < SimpleDelegator

  def self.wrap_collection(collection)
    collection.map { |object| self.new(object) }
  end

  def h
    ActionController::Base.helpers
  end

  alias_method :original_object, :__getobj__
end
