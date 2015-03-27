class Ldistance # http://rosettacode.org/wiki/Levenshtein_distance#Ruby

  CACHE = {}

  def self.cache_key_for(a,b)
    [a,b].sort.join(":")
  end

  def self.cache(a, b, distance)
    CACHE[self.cache_key_for(a,b)] = distance
  end

  def self.compute(a, b)
    cached = CACHE[self.cache_key_for(a,b)]

    return cached if cached.present?

    a, b = a.downcase, b.downcase
    costs = Array(0..b.length) # i == 0
    (1..a.length).each do |i|
      costs[0], nw = i, i - 1  # j == 0; nw is lev(i-1, j)
      (1..b.length).each do |j|
        costs[j], nw = [costs[j] + 1, costs[j-1] + 1, a[i-1] == b[j-1] ? nw : nw + 1].min, costs[j]
      end
    end
    result = costs[b.length]

    self.cache(a,b,result)

    result
  end

  def self.test
    %w{kitten sitting saturday sunday rosettacode raisethysword}.each_slice(2) do |a, b|
      puts "distance(#{a}, #{b}) = #{distance(a, b)}"
    end
  end

end
