require "priority-queue"

r = [] of Array(Int32)
File.each_line(ARGV[0]) do |l|
  l = l.chars.map(&.to_i)
  r << l +
       l.map { |x| (x + 1 - 1) % 9 + 1 } +
       l.map { |x| (x + 2 - 1) % 9 + 1 } +
       l.map { |x| (x + 3 - 1) % 9 + 1 } +
       l.map { |x| (x + 4 - 1) % 9 + 1 }
end
s = r.size
4.times do
  s.times do
    r << r[-s].map { |x| x % 9 + 1 }
  end
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
