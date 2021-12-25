c = Array(Tuple(Tuple(Int32, Int32, Int32, Int32, Int32, Int32), Bool)).new
xm = Array(Int32).new
ym = Array(Int32).new
zm = Array(Int32).new
File.each_line(ARGV[0]) do |l|
  if l =~ /^(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)$/
    v, xmin, xmax, ymin, ymax, zmin, zmax = $1 == "on", $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i, $7.to_i
    c << { {xmin, xmax + 1, ymin, ymax + 1, zmin, zmax + 1}, v }
    xm << xmin << xmax + 1
    ym << ymin << ymax + 1
    zm << zmin << zmax + 1
  end
end
xm = xm.sort.uniq
ym = ym.sort.uniq
zm = zm.sort.uniq
xh = xm.each_with_index.map { |p, i| [p, i] }.to_h
yh = ym.each_with_index.map { |p, i| [p, i] }.to_h
zh = zm.each_with_index.map { |p, i| [p, i] }.to_h
g = (0...xm.size).map do
  (0...ym.size).map do
    [0i8] * zm.size
  end
end
c.each do |(p, v)|
  xmin, xmax, ymin, ymax, zmin, zmax = p
  (xh[xmin]...xh[xmax]).each do |x|
    (yh[ymin]...yh[ymax]).each do |y|
      (zh[zmin]...zh[zmax]).each do |z|
        g[x][y][z] = v ? 1i8 : 0i8
      end
    end
  end
end
tot = 0i64
(0...xm.size).each do |x|
  (0...ym.size).each do |y|
    (0...zm.size).each do |z|
      if g[x][y][z] == 1i8
        tot += (xm[x + 1] - xm[x]).to_i64 * (ym[y + 1] - ym[y]).to_i64 * (zm[z + 1] - zm[z]).to_i64
      end
    end
  end
end
puts tot
