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
    loop do
      hex = b[p + 1, 4]
      p += 5
      break if b[p - 5] == 0
    end
    {v, p}
  else
    if b[6] == 0
      s = i(b[7, 15])
      from = 0
      while from < s
        vs, len = f(b[7 + 15 + from, s - from])
        v += vs
        from += len
      end
      {v, 7 + 15 + s}
    else
      l = i(b[7, 11])
      from = 0
      l.times do
        vs, len = f(b[7 + 11 + from..])
        v += vs
        from += len
      end
      {v, 7 + 11 + from}
    end
  end
end

b = File.read(ARGV[0]).chomp.chars.flat_map { |c| c.to_i(16).to_s(2).rjust(4, '0').chars.map(&.to_i) }

puts f(b)[0]
