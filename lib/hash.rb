# frozen_string_literal: true

# Adds `deep_transform_keys` method to Ruby hash
class Hash
  def deep_transform_keys(&block)
    _deep_transform_keys_in_object(self, &block)
  end

  private

  def _deep_transform_keys_in_object(object, &block)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[yield(key)] = _deep_transform_keys_in_object(value, &block)
      end
    when Array
      object.map { |e| _deep_transform_keys_in_object(e, &block) }
    else
      object
    end
  end
end
