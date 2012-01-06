<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>
  include RailsPanel::ActiveRecordInspector
<% attributes.select {|attr| attr.reference? }.each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>
end
<% end -%>
