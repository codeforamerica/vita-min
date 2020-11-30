module LinkToAddFieldsHelper
  def link_to_add_fields(name, form, association, options = {}, partial: nil)
    new_object = form.object.send(association).klass.new
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