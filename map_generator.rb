require 'byebug'
require 'yaml'
require 'ostruct'
require 'json'

class MapGenerator
  MIN_DIMENSION = 10
  MAX_DIMENSION = 20
  MAX_CHARS = 200
  yaml = File.read('data/nethack/map_features.yml')
  FEATURES = JSON.parse(YAML.load(yaml).to_json, object_class: OpenStruct)
  yaml = File.read('data/nethack/messages.yml')
  MESSAGES = JSON.parse(YAML.load(yaml).to_json, object_class: OpenStruct)
  FEATURE_MODIFER = 8
  attr_accessor :map

  def initialize(caption = false)
    @caption = caption
    @x = Random.rand(MIN_DIMENSION..MAX_DIMENSION) - 1
    @y = MAX_CHARS/@x - 1
    @tunnel_count = Random.rand(FEATURES.structural.tunnel.min..FEATURES.structural.tunnel.max)
    @door_count = Random.rand(FEATURES.structural.door.min..FEATURES.structural.door.max)
    @map = Array.new(@y) { Array.new(@x, FEATURES.structural.empty_space.char) }
    @locations = {}
  end

  def generate_filled_map
    add_room
    add_tunnels
    add_doors
    add_player
    add_optional_features
    add_monsters
    populate_messages << map_to_string("\n")
  end

  private

  def add_room
    starting_wall_x = Random.rand(0..@x)/2
    @width = Random.rand(4..(@x - starting_wall_x))
    starting_wall_y = Random.rand(0..@y)/2
    @height = Random.rand(4..(@y - starting_wall_y))
    @height.times do | y_coord |
      @width.times do | x_coord |
        assigned_char = assign_map_char(y_max: @height, x_max: @width, y: y_coord, x: x_coord)
        @map[starting_wall_y + y_coord][starting_wall_x + x_coord] = assigned_char
      end
    end
    puts "Creating a new room"
    puts "Overall map size X: #{@x} Y: #{@y}"
    puts "displaying room with width of #{@width}"
    puts "height of #{@height}"
    puts "starting x: #{starting_wall_x}, starting wall y: #{starting_wall_y}"
  end

  def add_player
    map_char = nil
    player_x = nil
    player_y = nil
    until FEATURES.player.valid_char.include? map_char
      player_y = Random.rand(0...@y)
      player_x = Random.rand(0...@x)
      map_char = @map[player_y][player_x]
    end
    @map[player_y][player_x] = FEATURES.player.char
    @locations[:player] = [player_y, player_x]
    @locations[:player_location_type] = map_char
  end

  def add_tunnels(prev_y: nil, prev_x: nil)
    return if enough_tunnels?
    if prev_x
      tunnel_x = 0
      tunnel_y = 0
      loop do
        tunnel_y = Random.rand(prev_y - 1..prev_y + 1)
        tunnel_x = Random.rand(prev_x - 1..prev_x + 1)
      break if (tunnel_x + 1 <= @x) && (tunnel_y + 1 <= @y)
      end
    else
      tunnel_y = Random.rand(0..@y - 1)
      tunnel_x = Random.rand(0..@x - 1 )
    end
    grab = @map[tunnel_y][tunnel_x]
    if grab == FEATURES.structural.empty_space.char && @map[tunnel_y][tunnel_x]
      @map[tunnel_y][tunnel_x] = FEATURES.structural.tunnel.char
    end
    add_tunnels(prev_y: tunnel_y, prev_x: tunnel_x)
  rescue => e
    # TODO Address assigning a tunnel outside the boundaries
  end

  def enough_tunnels?
    tunnel_spaces = map_to_string.chars.select {|char| char == FEATURES.structural.tunnel.char}.count
    tunnel_spaces >= @tunnel_count
  end

  def add_doors
    @door_count.times do
      char = ''
      until wall_char?(char)
        door_y = Random.rand(0..@y - 1)
        door_x = Random.rand(0..@x - 1)
        char = @map[door_y][door_x]
      end
      door_char = case char
      when FEATURES.structural.vertical_wall.char
        door_y.even? ? vertical_door : closed_door
      when FEATURES.structural.horizontal_wall.char
        door_y.even? ? horizontal_door : closed_door
      end
      @map[door_y][door_x] = door_char if door_char
    end
  end

  def horizontal_door
    FEATURES.structural.door.horizontal.char
  end

  def vertical_door
    FEATURES.structural.door.vertical.char
  end

  def closed_door
    FEATURES.structural.door.closed.char
  end

  def wall_char?(char)
    char == FEATURES.structural.vertical_wall.char || char == FEATURES.structural.horizontal_wall.char
  end

  def add_optional_features
    puts "width:" + @width.to_s
    puts "height:" + @height.to_s
    puts max_feature_count.to_s
    feature_count = 0

    optional_feature_types.each do |type|
      break if feature_count >= max_feature_count
      type_count = Random.rand(FEATURES.optional.send(type).min..FEATURES.optional.send(type).max)
      type_count.times do
        char = ''
        until char == FEATURES.structural.ground.char
          feature_y = Random.rand(0..@y - 1)
          feature_x = Random.rand(0..@x - 1)
          char = @map[feature_y][feature_x]
        end
        @map[feature_y][feature_x] = FEATURES.optional.send(type).char
        feature_count += 1
        break if feature_count >= max_feature_count
      end
    end
  end

  def optional_feature_types
    FEATURES.optional.marshal_dump.keys.shuffle
  end

  def max_feature_count
    (@width + @height)/FEATURE_MODIFER
  end

  def add_monsters

  end

  def in_proximity?(type, coordinates)
    player_y = @locations[:player].first
    player_x = @locations[:player].last
    modifier = FEATURES.structural.send(type).proximity
    diff = (player_y - coordinates.first).abs + (player_x  - coordinates.last).abs
    puts diff
    puts "Coordinates: #{coordinates}"
    puts "y: #{player_y}"
    puts "x: #{player_x}"
    puts "diff #{diff}"
    diff <= modifier
  rescue => e
  end

  def save_flavor_text(type)
    @flavor << FEATURES.structural.send(type).flavor.sample
    puts @flavor
  rescue => e
    byebug
  end

  def assign_map_char(y_max:, x_max:, y:, x:)
    if y == y_max - 1 || y == 0
      FEATURES.structural.horizontal_wall.char
    elsif x == x_max - 1 || x == 0
      FEATURES.structural.vertical_wall.char
    else
      FEATURES.structural.ground.char
    end
  end

  def map_to_string(break_char = "")
    map = @map.inject('') do | acc, row |
      string_row = row.join << break_char
      acc << string_row
    end
  end

  def stringify(break_char = "")
    map = @map.inject('') do | acc, row |
      string_row = row.join << break_char
      acc << string_row
    end
  end

  def populate_messages
    message_type = message_types.shuffle.first
    MESSAGES.send(message_type).text.sample + "\n\n" if appropriate_location?(message_type)
  end

  def appropriate_location?(type)
    (MESSAGES.send(type).room_only && @locations[:player_location_type] == FEATURES.structural.ground.char) || !MESSAGES.send(type).room_only
  end

  def message_types
    MESSAGES.marshal_dump.keys
  end
end

m = MapGenerator.new
m.generate_filled_map
