c = Hash(Tuple(Int32, Int32, Int32), Bool).new
File.each_line(ARGV[0]) do |l|
  if l =~ /^(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)$/
    v, xmin, xmax, ymin, ymax, zmin, zmax = $1 == "on", $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i, $7.to_i

    ({xmin, -50}.max..{xmax, 50}.min).each do |x|
      ({ymin, -50}.max..{ymax, 50}.min).each do |y|
        ({zmin, -50}.max..{zmax, 50}.min).each do |z|
          c[{x, y, z}] = v
        end
      end
    end
  end
end
puts c.each_value.count { |v| v }
