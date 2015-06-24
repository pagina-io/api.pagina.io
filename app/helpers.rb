module JikkyllHelpers

  def api_response(object = {})
    if object.is_a?(Array)
      object.inject([]) do |hash, row|
        hash << recurse_through_object(row)
        hash
      end.to_json
    else
      recurse_through_object(object).to_json
    end
  end

  def recurse_through_object(object = {})
    if is_a_data_class?(object)
      return object
    elsif object.is_a?(Array)
      return object.inject([]) do |arr, row|
        arr << recurse_through_object(row)
      end
    else
      return object.to_h.inject({}) do |hash, (k, v)|
        hash[k] = recurse_through_object(v)
        hash
      end
    end
  end

  def is_a_data_class?(klass)
    %w(String TrueClass FalseClass Fixnum Time).include?(klass.class.name)
  end

end
