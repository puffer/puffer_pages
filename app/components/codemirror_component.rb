class CodemirrorComponent < BaseComponent
  helper_method :buttons

private

  def buttons
    PufferPages.codemirror_buttons + Array.wrap(field.options[:buttons])
  end
end