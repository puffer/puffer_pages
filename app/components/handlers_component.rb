class HandlersComponent < SelectComponent

private

  def select_options
    PufferPages::Handlers.select
  end
end
