require 'byebug'

class MapGenerator
  MIN_DIMENSION = 7
  MAX_DIMENSION = 20
  MAX_CHARS = 140

  attr_accessor :map

  def initialize(caption = false)
    @caption = caption
    @map = []
    @x = Random.rand(MIN_DIMENSION..MAX_DIMENSION) - 1
    @y = MAX_CHARS/@x - 1
    @map = Array.new(@y) { Array.new(@x, "") }
  end

  def generate_filled_map
    while filled? == false
      starting_wall_x, width = Random.rand(0..@x)/2, Random.rand(2..@x)
      starting_wall_y, height = Random.rand(0..@y), Random.rand(2..@y)
      byebug
      width.times do | x_coord |
        @map[0][starting_wall_x + x_coord] = "|"
      end
      byebug
      puts stringify
    end
  end

  private
  def stringify
    map_string = ""
    @map.each_with_index do | row, index |
      row.each do |char|
        if row.count == index
          map_string << char + '/n'
        else
          map_string << char
        end
      end
    end
    map_string
  end

  def filled?
    @map.any? { |char| char == "" }
  end
  # def [](x, y)
  #   @map[x][y]
  # end

  # def []=(x, y, value)
  #   @map[x[y]] = value
  # end

end

m = MapGenerator.new
puts m.generate_filled_map
