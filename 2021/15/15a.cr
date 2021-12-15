require "priority-queue"

r = [] of Array(Int32)
File.each_line(ARGV[0]) do |l|
  r << l.chars.map(&.to_i)
end
vis = Set(Array(Int32)).new
a = Priority::Queue(Array(Int32)).new
a.push(0, [0, 0])
until a.empty?
  x = a.shift
  p = x.priority
  v = x.value

  next if vis.includes?(v)
  vis << v

  a.push(p + r[v[0] - 1][v[1]], [v[0] - 1, v[1]]) if v[0] - 1 >= 0
  a.push(p + r[v[0] + 1][v[1]], [v[0] + 1, v[1]]) if v[0] + 1 < r.size
  a.push(p + r[v[0]][v[1] - 1], [v[0], v[1] - 1]) if v[1] - 1 >= 0
  a.push(p + r[v[0]][v[1] + 1], [v[0], v[1] + 1]) if v[1] + 1 < r[0].size

  if v == [r.size - 1, r[0].size - 1]
    puts p
    break
  end
end
