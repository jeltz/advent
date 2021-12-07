fish = File.read(ARGV[0]).strip.split(/,/).map(&.to_i)
80.times do
  n = 0
  fish.each_with_index do |f, i|
    if f == 0
      fish[i] = 6
      n += 1
    else
      fish[i] -= 1
    end
  end
  n.times { fish << 8 }
end
puts fish.size
