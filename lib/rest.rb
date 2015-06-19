module REST
  def create_resource resource, path
    get "/#{path}" do
      respond_with(resource.all, path)
    end

    get "/#{path}/:id" do
      respond_with(resource.first(id: params[:id]), path)
    end

    post "/#{path}" do
      respond_with(resource.all, path)
    end

    put "/#{path}/:id" do
      respond_with(resource.first(id: params[:id]), path)
    end

    delete "/#{path}/:id" do
      respond_with('', path)
    end
  end

end
