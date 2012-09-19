class PagePartsComponent < Puffer::Component::Base

  helper_method :localized?

  def form
    render
  end

private

  def localized?
    !!field.options[:localized]
  end

end