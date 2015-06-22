module REST

  def self.respond_with data, enclosure
    response = {}

    if data.is_a?(Array)
      response[enclosure.to_sym] = []

      data.each do |row|
        response[enclosure.to_sym] << row.readable
      end
    else
      response[enclosure.to_sym] = data
    end

    response.to_json
  end

  def create_resource resource, path
    get "/#{path}/?" do
      if resource.authorized?(params[:access_token])
        _resources = resource.all
      else
        _resources = []
      end

      REST.respond_with(_resources, path)
    end

    get "/#{path}/:id/?" do
      _resource = resource.first(id: params[:id].to_i)

      if !_resource.authorized?(params[:access_token])
        status 401
        _resource = []
      else
        _resource = _resource.readable
      end

      REST.respond_with(_resource, path)
    end

    post "/#{path}/?" do
      if resource.authorized?(params[:access_token])
        _resource = resource.new(resource.filter(params))
        _resource._access_token = params[:access_token]
        _resource.save
        _resource = _resource.readable
        status 201
      else
        _resource = ''
        status 401
      end

      REST.respond_with(_resource, path)
    end

    put "/#{path}/:id/?" do
      _resource = resource.first(id: params[:id].to_i)

      if _resource.authorized?(params[:access_token])
        _resource.update(resourse.filter(params)).readable
      else
        status 401
        _resource = ''
      end

      REST.respond_with(_resource, path)
    end

    delete "/#{path}/:id/?" do
      _resource = resource.first(id: params[:id].to_i)

      if _resource.authorized?(params[:access_token])
        _resource.delete
        status 204
      else
        status 401
      end

      REST.respond_with('', path)
    end
  end

end
