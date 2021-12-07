count = 0
File.each_line(ARGV[0]).each_cons(2) do |(a, b)|
  count += 1 if b.to_i > a.to_i
end
puts count
