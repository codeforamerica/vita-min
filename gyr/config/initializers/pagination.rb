module PaginationPatch
  # defend against params[:page] being something other than a number
  def page(page_number)
    super(page_number.to_i.zero? ? 1 : page_number.to_i)
  end
end

Rails.application.reloader.to_prepare do
  klasses = [ActiveRecord::Relation, ActiveRecord::Associations::CollectionProxy]

  # support pagination on associations and scopes
  klasses.each { |klass| klass.send(:include, PaginationPatch) }
end
