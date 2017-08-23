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
    @map = Array.new(@y) { Array.new(@x, "#") }
  end

  def generate_filled_map
    filled = false
    while filled == false
      starting_wall_x = Random.rand(0..@x)/2
      width = Random.rand(4..(@x - starting_wall_x))
      starting_wall_y = Random.rand(0..@y)/2
      height = Random.rand(4..(@y - starting_wall_y))
      height.times do | y_coord |
        width.times do | x_coord |
          assigned_char = assign_map_char(y_max: height, x_max: width, y: y_coord, x: x_coord)
          @map[starting_wall_y + y_coord][starting_wall_x + x_coord] = assigned_char
        end
      end
      filled = true
      puts "Overall map size X: #{@x} Y: #{@y}"
      puts "displaying room with width of #{width}"
      puts "height of #{height}"
      puts "starting x: #{starting_wall_x}, starting wall y: #{starting_wall_y}"
      add_player
      stringify
    end
  end

  private

  def add_player
    map_char = nil
    player_x = nil
    player_y = nil
    until valid_player_locations.include? map_char
      player_y = Random.rand(0...@y)
      player_x = Random.rand(0...@x)
      map_char = @map[player_y][player_x]
    end
    @map[player_y][player_x] = "@"
  end

  def valid_player_locations
    [".", "|", "_"]
  end

  def assign_map_char(y_max:, x_max:, y:, x:)
    if y == y_max - 1 || y == 0
      "-"
    elsif x == x_max - 1 || x == 0
      "|"
    else "."
    end
  end

  def stringify
    @map.each do |r|
      puts r.each { |char| char }.join('')
    end
  end

  def filled?
    true
    # @map.any? { |char| char == " " }
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
