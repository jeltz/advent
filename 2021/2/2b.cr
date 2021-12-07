x, d, a = 0, 0, 0
File.each_line(ARGV[0]) do |l|
  case l
  when /^forward (\d+)/
    x += $1.to_i
    d += $1.to_i * a
  when /^down (\d+)/
    a += $1.to_i
  when /^up (\d+)/
    a -= $1.to_i
  end
end
puts x * d
