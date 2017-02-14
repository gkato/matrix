require 'inputs'

describe Inputs do

  describe ".combine_arrays" do
    context "given two arrays and relative keys" do
      it "returns a array with the given elments combined paired with the provided keys" do
        result = Inputs.combine_arrays([1,2], [3,4], :gain_1, :gain_2)
        expected = [{gain_1:1, gain_2:3}, {gain_1:1, gain_2:4}, {gain_1:2, gain_2:3}, {gain_1:2, gain_2:4}]
        expect(result).to eq(expected)
      end
    end
  end

  describe ".combine_array_map" do
    context "given an arrays and a map" do
      it "returns a array with the given elments combined paired with the provided key" do
        result = Inputs.combine_array_map([1,2], [{gain_1:3, gain_2:4}], :stop)
        expected = [{stop:1, gain_1:3, gain_2:4}, {stop:2, gain_1:3, gain_2:4}]
        expect(result).to eq(expected)
      end
    end
  end

  describe ".combine_array_map" do
    context "given an arrays, a maps and an additional map" do
      it "returns a array with the given elments combined paired with the provided key, added to an additional map" do
        result = Inputs.combine_array_map([1,2], [{gain_1:3, gain_2:4}], :start, {net:0})
        expected = [{start:1, gain_1:3, gain_2:4, net:0}, {start:2, gain_1:3, gain_2:4, net:0}]
        expect(result).to eq(expected)
      end
    end
  end
end
