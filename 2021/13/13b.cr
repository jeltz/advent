dots = [] of Array(Int32)
File.open(ARGV[0]) do |ff|
  while !(l = ff.gets || "").empty?
    dots << l.split(/,/).map(&.to_i)
  end
  while l = ff.gets
    case l
    when /^fold along x=(\d+)$/
      f = $1.to_i
      dots = dots.map { |(x, y)| [x > f ? f - (x - f) : x, y] }.uniq
    when /^fold along y=(\d+)$/
      f = $1.to_i
      dots = dots.map { |(x, y)| [x, y > f ? f - (y - f) : y] }.uniq
    end
  end
  (0..dots.map { |(_, y)| y }.max).each do |y|
    puts (0..dots.map { |(x, _)| x }.max).map { |x| dots.includes?([x, y]) ? '#' : ' ' }.join
  end
end
