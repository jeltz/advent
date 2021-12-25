D = [1, 2, 3].flat_map { |a| [1, 2, 3].flat_map { |b| [1, 2, 3].map { |c| a + b + c } } }.group_by { |x| x }.map { |v, vs| {v, vs.size} }

def fa(a, b, ap, bp)
  D.map do |v, c|
    p = (ap + v - 1) % 10 + 1
    if a + p >= 21
      {c.to_i64, 0i64}
    else
      x, y = fb(a + p, b, p, bp)
      {x * c, y * c}
    end
  end.reduce({0i64, 0i64}) { |(a, b), (c, d)| {a + c, b + d} }
end

def fb(a, b, ap, bp)
  D.map do |v, c|
    p = (bp + v - 1) % 10 + 1
    if b + p >= 21
      {0i64, c.to_i64}
    else
      x, y = fa(a, b + p, ap, p)
      {x * c, y * c}
    end
  end.reduce({0i64, 0i64}) { |(a, b), (c, d)| {a + c, b + d} }
end

File.open(ARGV[0]) do |f|
  f.read_line =~ /^Player 1 starting position: (\d+)$/
  ap = $1.to_i
  f.read_line =~ /^Player 2 starting position: (\d+)$/
  bp = $1.to_i
  puts fa(0, 0, ap, bp).max
end
