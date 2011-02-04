class PufferPages::Base < Puffer::Base
  unloadable

  helper :puffer_pages

  configure do
    group :cms
  end

end
