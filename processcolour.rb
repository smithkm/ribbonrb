colours = {}
$stdin.each_line do |line|
  if line =~ /^\s*\$this->(\w+)\s*=\s*imagecolorallocate\(\$this->ribbon,(\s*\d+\s*,\s*\d+\s*,\s*\d+)\s*\);$/
    colours[$1]=$2
  end
end

max_length = colours.keys.map{|key| key.length}.max

colours.each_pair do |key, colour|
  puts "#{key.upcase.ljust max_length} = [#{colour}]"
end
