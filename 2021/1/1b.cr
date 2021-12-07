count = 0
File.each_line(ARGV[0]).each_cons(4) do |(a, _, _, b)|
  count += 1 if b.to_i > a.to_i
end
puts count
