def f(map, i, j)
  return 0 if map[i][j] == 9
  map[i][j] = 9
  1 + f(map, i - 1, j) + f(map, i + 1, j) + f(map, i, j - 1) + f(map, i, j + 1)
end

map = [[9] * 102] of Array(Int32)
File.each_line(ARGV[0]) do |l|
  map << [9] + l.chars.map(&.to_i) + [9]
end
map << [9] * 102
basins = [] of Int32
(1..map.size - 2).each do |i|
  (1..map[i].size - 2).each do |j|
    if map[i][j] < 9
      basins << f(map, i, j)
    end
  end
end
b = basins.sort.reverse
puts b[0] * b[1] * b[2]
