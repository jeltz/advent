def i(b)
  n = 0
  b.each do |x|
    n <<= 1
    n |= 1 if x == 1
  end
  n
end

def f(b)
  raise "Too short" if b.size < 6
  v = i(b[0, 3])
  t = i(b[3, 3])

  if t == 4
    p = 6
    n = 0i64
    loop do
      n <<= 4
      n |= i(b[p + 1, 4])
      p += 5
      break if b[p - 5] == 0
    end
    {n, p}
  else
    vals = [] of Int64
    if b[6] == 0
      s = i(b[7, 15])
      from = 0
      while from < s
        vs, len = f(b[7 + 15 + from, s - from])
        vals << vs
        from += len
      end
      consume = 7 + 15 + s
    else
      l = i(b[7, 11])
      from = 0
      l.times do
        vs, len = f(b[7 + 11 + from..])
        vals << vs
        from += len
      end
      consume = 7 + 11 + from
    end

    case t
    when 0
      {vals.sum, consume}
    when 1
      {vals.product, consume}
    when 2
      {vals.min, consume}
    when 3
      {vals.max, consume}
    when 5
      {vals[0] > vals[1] ? 1i64 : 0i64, consume}
    when 6
      {vals[0] < vals[1] ? 1i64 : 0i64, consume}
    when 7
      {vals[0] == vals[1] ? 1i64 : 0i64, consume}
    else
      raise "Unknown operator"
    end
  end
end

b = File.read(ARGV[0]).chomp.chars.flat_map { |c| c.to_i(16).to_s(2).rjust(4, '0').chars.map(&.to_i) }

puts f(b)[0]
