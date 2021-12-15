dots = [] of Array(Int32)
File.open(ARGV[0]) do |f|
  while !(l = f.gets || "").empty?
    dots << l.split(/,/).map(&.to_i)
  end
  if l = f.gets
    case l
    when /^fold along x=(\d+)$/
      f = $1.to_i
      puts dots.map { |(x, y)| [x > f ? f - (x - f) : x, y] }.uniq.size
    when /^fold along y=(\d+)$/
      f = $1.to_i
      puts dots.map { |(x, y)| [x, y > f ? f - (y - f) : y] }.uniq.size
    end
  end
end
