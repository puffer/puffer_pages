class PufferPages::OriginsBase < Puffer::Base
  skip_before_filter :require_puffer_user, only: :export

  member do
    get :import
  end

  collection do
    get :export, display: false
  end

  def import
    @record = resource.member
    @record.import!
    redirect_to admin_origins_path
  end

  def export
    if params[:token] == PufferPages.access_token
      render json: resource.model.export_json
    else
      render nothing: true, status: 401
    end
  end

  setup do
    group :pages
    model_name :'puffer_pages/origin'
  end

  index do
    field :name
    field :uri
    field :token
  end

  form do
    field :name
    field :host
    field :path
    field :token
  end
end
