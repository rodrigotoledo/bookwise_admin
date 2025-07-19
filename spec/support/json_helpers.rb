# spec/support/json_helpers.rb
module JsonHelpers
  def include_json_subset?(subset, json)
    case json
    when Array
      json.any? { |item| subset.to_a - item.to_a == [] }
    when Hash
      subset.to_a - json.to_a == []
    else
      false
    end
  end
end
