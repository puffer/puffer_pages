class CodemirrorComponent < BaseComponent
  class_attribute :buttons
  self.buttons = [:fullscreen]

  helper_method :buttons

end