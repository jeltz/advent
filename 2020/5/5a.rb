p STDIN.each_line.map { |l| l.tr('BRFL', '1100').to_i(2) }.max
