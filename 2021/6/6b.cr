require "big"

fish = File.read(ARGV[0]).strip.split(/,/).map(&.to_i)
s = (0...256).map { BigInt.new(0) }
fish.each { |f| (0...256).each { |n| s[n] += 1 if (n - f) % 7 == 0 } }
(0...256).each do |d|
  v = 8
  (d + 1...256).each do |n|
    if v == 0
      v = 6
      s[n] += s[d]
    else
      v -= 1
    end
  end
end
puts fish.size + s.sum
