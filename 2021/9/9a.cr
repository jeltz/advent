map = [[10] * 102] of Array(Int32)
File.each_line(ARGV[0]) do |l|
  map << [10] + l.chars.map(&.to_i) + [10]
end
map << [10] * 102
low = 0
basins = [] of Int32
(1..map.size - 2).each do |i|
  (1..map[i].size - 2).each do |j|
    if map[i][j] < map[i - 1][j] &&
       map[i][j] < map[i + 1][j] &&
       map[i][j] < map[i][j - 1] &&
       map[i][j] < map[i][j + 1]
      low += map[i][j] + 1
    end
  end
end
puts low
