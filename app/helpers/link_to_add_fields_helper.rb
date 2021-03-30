module LinkToAddFieldsHelper
  def link_to_add_fields(name, form, association, options = {}, partial: nil)
    new_object = if options[:no_association]
                   association.to_s.singularize.classify.constantize.new # force creation of new element when there is no "association" on the form object
                 else
                   form.object.send(association).klass.new
                 end
    id = new_object.object_id
    fields = form.fields_for(association, new_object, child_index: id) do |builder|
      render(partial, f: builder)
    end
    data = options[:data] || {}
    options[:data] = data.merge(
      link_to_add_field_id: id,
      link_to_add_field: fields.delete("\n")
    )
    link_to name, '#', options
  end

  def link_to_remove_fields(name, target, options = {})
    data = options[:data] || {}
    options[:data] = data.merge(link_to_remove_field: target)
    link_to name, '#', options
  end
end