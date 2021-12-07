x, d = 0, 0
File.each_line(ARGV[0]) do |l|
  case l
  when /^forward (\d+)/
    x += $1.to_i
  when /^down (\d+)/
    d += $1.to_i
  when /^up (\d+)/
    d -= $1.to_i
  end
end
puts x * d
