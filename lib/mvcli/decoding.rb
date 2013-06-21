require "map"

class MVCLI::Decoding
  def initialize
    @enrichments = Map.new do |h,k|
      h[k] = []
    end
  end

  def call(name, value, target = Object)
    if target.is_a?(Array)
      [value].flatten.map {|element| call name, element, target.first}
    else
      @enrichments[name].reduce value do |value, enrichment|
        enrichment.call value
      end
    end
  end

  def method_missing(name, &block)
    fail "must supply a block to transform value named '#{name}'" unless block
    @enrichments[name] << block
    return self
  end
end
