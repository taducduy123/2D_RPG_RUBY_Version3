def get_Map(map)
  numbers = []
  File.open(map, 'r') do |file|
    file.each_line do |line|
      # Split the line by spaces or commas and convert each part to an integer
      sub_array = line.split(/[\s,]+/).map { |num| num.strip.to_i }
      numbers << sub_array
    end
  end
  return numbers
end
