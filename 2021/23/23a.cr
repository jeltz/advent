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
      if ({x, h}.min..{x, h}.max).all? { |xx| xx == x || !m.fetch({xx, 1}, nil) } && m[{h, 2}] == nil
        if m[{h, 3}] == s
          sh[i] = {s, h, 2}
          m[{x, y}], m[{h, 2}] = nil, s
          f(sh, m, c + COST[s] * ((x - h).abs + 1), res)
          sh[i] = {s, x, y}
          m[{x, y}], m[{h, 2}] = s, nil
        elsif m[{h, 3}] == nil
          sh[i] = {s, h, 3}
          m[{x, y}], m[{h, 3}] = nil, s
          f(sh, m, c + COST[s] * ((x - h).abs + 2), res)
          sh[i] = {s, x, y}
          m[{x, y}], m[{h, 3}] = s, nil
        end
      end
    when 2
      if HOMES[s] == x && m[{x, 3}] == s
        ok += 1
      else
        TARGETS.each do |t|
          next unless ({x, t}.min..{x, t}.max).all? { |xx| !m.fetch({xx, 1}, nil) }

          sh[i] = {s, t, 1}
          m[{x, y}], m[{t, 1}] = nil, s
          f(sh, m, c + COST[s] * ((x - t).abs + 1), res)
          sh[i] = {s, x, y}
          m[{x, y}], m[{t, 1}] = s, nil
        end
      end
    when 3
      if HOMES[s] == x
        ok += 1
      elsif m[{x, 2}] == nil
        TARGETS.each do |t|
          next unless ({x, t}.min..{x, t}.max).all? { |xx| !m.fetch({xx, 1}, nil) }

          sh[i] = {s, t, 1}
          m[{x, y}], m[{t, 1}] = nil, s
          f(sh, m, c + COST[s] * ((x - t).abs + 2), res)
          sh[i] = {s, x, y}
          m[{x, y}], m[{t, 1}] = s, nil
        end
      end
    end
  end
  res[0] = c if ok == 8 && c < res[0]
end

map = File.read(ARGV[0]).lines

sh = [] of Tuple(Char, Int32, Int32)
m = Hash(Tuple(Int32, Int32), Char | Nil).new
(0...map.size).each do |y|
  (0...map[y].size).each do |x|
    next unless ('A'..'D').includes?(map[y][x])
    sh << {map[y][x], x, y}
    m[{x, y}] = map[y][x]
  end
end

res = [1 << 30]
f(sh.sort, m, 0, res)
puts res[0]
