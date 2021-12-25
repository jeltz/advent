TARGETS = [1, 2, 4, 6, 8, 10, 11]
HOMES   = {
  'A' => 3,
  'B' => 5,
  'C' => 7,
  'D' => 9,
}
COST = {
  'A' => 1,
  'B' => 10,
  'C' => 100,
  'D' => 1000,
}

SEEN = Hash(Array(Tuple(Char, Int32, Int32)), Int32).new

def f(sh, m, c, res)
  shh = sh.sort
  return if SEEN.fetch(shh, 1 << 30) <= c
  SEEN[shh] = c
  ok = 0
  sh.each_with_index do |(s, x, y), i|
    case y
    when 1
      h = HOMES[s]
      if ({x, h}.min..{x, h}.max).all? { |xx| xx == x || !m[{xx, 1}] }
        dd = (2..5).find { |yy| m[{h, yy}] != nil } || 6
        next unless (dd..5).all? { |yy| m[{h, yy}] == s }
        ny = dd - 1

        sh[i] = {s, h, ny}
        m[{x, y}], m[{h, ny}] = nil, s
        f(sh, m, c + COST[s] * ((x - h).abs + ny - 1), res)
        sh[i] = {s, x, y}
        m[{x, y}], m[{h, ny}] = s, nil
      end
    when 2, 3, 4, 5
      if HOMES[s] == x && (y + 1..5).all? { |yy| m[{x, yy}] == s }
        ok += 1
      elsif (2...y).all? { |yy| m[{x, yy}] == nil }
        TARGETS.each do |t|
          next unless ({x, t}.min..{x, t}.max).all? { |xx| !m[{xx, 1}] }

          sh[i] = {s, t, 1}
          m[{x, y}], m[{t, 1}] = nil, s
          f(sh, m, c + COST[s] * ((x - t).abs + y - 1), res)
          sh[i] = {s, x, y}
          m[{x, y}], m[{t, 1}] = s, nil
        end
      end
    end
  end
  if ok == sh.size && c < res[0]
    res[0] = c
    p c
  end
end

map = File.read(ARGV[0]).lines
map = [*map[0..2], "  #D#C#B#A#", "  #D#B#A#C#", *map[3..4]]

sh = [] of Tuple(Char, Int32, Int32)
m = Hash(Tuple(Int32, Int32), Char | Nil).new
(0...map.size).each do |y|
  (0...map[y].size).each do |x|
    sh << {map[y][x], x, y} if ('A'..'D').includes?(map[y][x])
    m[{x, y}] = ('A'..'D').includes?(map[y][x]) ? map[y][x] : nil
  end
end

res = [1 << 30]
f(sh.sort, m, 0, res)
puts res[0]
