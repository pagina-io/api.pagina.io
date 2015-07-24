module REST

  def self.bearer_token(header, params)
    return false if header.nil? && params[:access_token].nil?
    return params[:access_token] unless params[:access_token].nil?
    header.split(' ').last
  end

  def self.respond_with(data, enclosure = nil)
    if data.is_a?(Sequel::Dataset) || data.is_a?(Array)
      response = data.inject([]) do |array, value|
        array << REST.respond_with(value)
        array
      end
    elsif data.class.ancestors.include?(Enumerable)
      response = data.inject({}) do |hash, (key, value)|
        hash[key] = REST.respond_with(value)
        hash
      end
    elsif data.class.ancestors.include?(Sequel::Model)
      response = data.readable(enclosure.nil?).inject({}) do |hash, (key, value)|
        if data.class._readable.include?(key) && (!enclosure.nil? || !data.class._exclude_from_search.include?(key))
          hash[key] = REST.respond_with(value)
        end

        hash
      end
    else
      response = data
    end

    return response if enclosure.nil?

    enclosed = {}
    enclosed[enclosure] = response

    return Oj.dump(enclosed, mode: :compat)
  end

  def self.parse_searchables params
    params.inject({}) do |hash, (key, value)|
      hash[key.to_sym] = value
      hash
    end
  end

  def create_resource resource, path
    get "/#{path}/?" do
      token = REST.bearer_token(env['HTTP_AUTHORIZATION'], params)

      if resource.authorized?(token) && REST.parse_searchables(params).count > 0
        _resources = resource.search_using(REST.parse_searchables(params))
      else
        _resources = []
      end

      REST.respond_with(_resources, path)
    end

    get "/#{path}/:id/?" do
      token = REST.bearer_token(env['HTTP_AUTHORIZATION'], params)
      _resource = resource.first(id: params[:id].to_i)

      if !_resource.authorized?(token)
        status 401
        _resource = []
      else
        _resource = _resource.readable
      end

      REST.respond_with(_resource, path)
    end

    post "/#{path}/?" do
      token = REST.bearer_token(env['HTTP_AUTHORIZATION'], params)

      if resource.authorized?(token)
        _resource = resource.new(resource.filter(params))
        _resource._access_token = token
        if _resource.save
          _resource = _resource.readable
          status 201
        else
          _resource = []
          status 500
        end
      else
        _resource = ''
        status 401
      end

      REST.respond_with(_resource, path)
    end

    put "/#{path}/:id/?" do
      token = REST.bearer_token(env['HTTP_AUTHORIZATION'], params)
      _resource = resource.first(id: params[:id].to_i)

      if !_resource.nil? && _resource.authorized?(token)
        _resource._access_token = token
        _resource.update(resource.filter(params))
        _resource = _resource.readable
      else
        status 401
        _resource = []
      end

      REST.respond_with(_resource, path)
    end

    delete "/#{path}/:id/?" do
      token = REST.bearer_token(env['HTTP_AUTHORIZATION'], params)
      _resource = resource.first(id: params[:id].to_i)

      if _resource.authorized?(token)
        _resource._access_token = token
        _resource.destroy
        status 204
      else
        status 401
      end

      REST.respond_with('', path)
    end
  end

end
