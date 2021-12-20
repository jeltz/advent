require "matrix"

ROT = [{0, 0}, {1, 0}, {2, 0}, {3, 0}, {0, 1}, {0, 3}].flat_map do |(x, y)|
  (0..3).map do |z|
    ax, ay, az = x * Math::PI / 2, y * Math::PI / 2, z * Math::PI / 2

    rx = Matrix.rows([[1, 0, 0], [0, cos(ax), -sin(ax)], [0, sin(ax), cos(ax)]])
    ry = Matrix.rows([[cos(ay), 0, sin(ay)], [0, 1, 0], [-sin(ay), 0, cos(ay)]])
    rz = Matrix.rows([[cos(az), -sin(az), 0], [sin(az), cos(az), 0], [0, 0, 1]])

    rx * ry * rz
  end
end

def cos(a)
  Math.cos(a).round.to_i
end

def sin(a)
  Math.sin(a).round.to_i
end

def rot(d, i)
  r = ROT[i]
  d.map do |x|
    (r * Matrix.columns([x])).columns[0]
  end
end

def cmp(a, b)
  (0..23).each do |i|
    bb = rot(b, i)

    a.each do |x|
      bb.each do |y|
        o = [x[0] - y[0], x[1] - y[1], x[2] - y[2]]
        count = 0
        bb.each do |z|
          count += 1 if a.includes?([z[0] + o[0], z[1] + o[1], z[2] + o[2]])
        end
        return {i, o} if count >= 12
      end
    end
  end
end

scanners = [] of Array(Array(Int32))
File.open(ARGV[0]) do |f|
  loop do
    beacons = [] of Array(Int32)
    f.gets
    l = nil
    loop do
      l = f.gets
      break if l == nil || l == ""
      beacons << l.split(/,/).map(&.to_i) if l
    end
    scanners << beacons
    break if l == nil
  end
end

q = [0]
ok = Set{0}

q.each do |i|
  (0...scanners.size).each do |j|
    next if ok.includes?(j)
    c = cmp(scanners[i], scanners[j])
    if c
      n = rot(scanners[j], c[0])
      scanners[j] = n.map { |x| [x[0] + c[1][0], x[1] + c[1][1], x[2] + c[1][2]] }
      ok << j
      q << j
    end
  end
end

puts scanners.flat_map { |x| x }.uniq.size
