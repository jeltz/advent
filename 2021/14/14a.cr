rules = Hash(Array(Char), Char).new

File.open(ARGV[0]) do |f|
  t = f.read_line.chars
  f.gets
  while l = f.gets
    r, n = l.split(/ -> /)
    rules[r.chars] = n[0]
  end

  10.times do
    n = [] of Char
    t.each_cons(2) do |p|
      n << p[0]
      if rules[p]
        n << rules[p]
      end
    end
    n << t[-1]
    t = n
  end
  counts = Hash(Char, Int64).new(0)
  t.each { |c| counts[c] += 1 }
  puts counts.values.max - counts.values.min
end
