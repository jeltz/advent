rules = Hash(Array(Char), Char).new

File.open(ARGV[0]) do |f|
  t = f.read_line.chars
  f.gets
  while l = f.gets
    r, n = l.split(/ -> /)
    rules[r.chars] = n[0]
  end

  ps = Hash(Array(Char), Int64).new(0)
  t.each_cons(2) do |p|
    ps[p] += 1
  end

  40.times do |i|
    n = Hash(Array(Char), Int64).new(0)
    ps.each do |p, c|
      if rules[p]
        n[[p[0], rules[p]]] += c
        n[[rules[p], p[1]]] += c
      else
        n[p] += c
      end
    end
    ps = n
  end

  counts = Hash(Char, Int64).new(0)
  ps.each { |p, c| counts[p[0]] += c }
  counts[t[-1]] += 1
  puts counts.values.max - counts.values.min
end
