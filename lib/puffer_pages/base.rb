class PufferPages::Base < Puffer::Base
  unloadable

  configure do
    group :cms
  end

end
