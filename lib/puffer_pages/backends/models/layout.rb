class PufferPages::Backends::Layout < ActiveRecord::Base
  include ActiveUUID::UUID
  include PufferPages::Backends::Mixins::Renderable
  include PufferPages::Backends::Mixins::Importable
  include PufferPages::Backends::Mixins::Translatable
  self.abstract_class = true
  self.table_name = :layouts

  attr_protected

  validates_presence_of :name
  validates_uniqueness_of :name

  def self.find_layout(name)
    where(:name => name).first
  end

  def render *args
    _, context = normalize_render_options *args
    render_template body, context, additional_render_options
  end

  def additional_render_options
    { environment: { processed: self } }
  end

  def i18n_scope
    [:layouts, name.to_sym]
  end

  def i18n_defaults
    []
  end
end
