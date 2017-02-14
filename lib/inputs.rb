class Inputs

  def self.combine_arrays(array_1, array_2, key_1, key_2)
    result = array_1.product(array_2)
    result.map { |pair| { key_1 => pair[0], key_2 => pair[1] } }
  end

  def self.combine_array_map(arr, maps, key, extra={})
    result = arr.product(maps)
    result.map { |el| {key => el[0]}.merge(el[1]).merge(extra) }
  end

end
