require 'ruby2d'

set width: 1920, height: 1080, background: 'gray', title: 'Achtung die Kurve'

WIDTH, HEIGHT = 1920, 1080
SNAKE_SIZE = 8
FPS = 15

class Player
  attr_accessor :body, :direction

  def initialize(color, x, y)
    @color = color
    @body = [Circle.new(x: x, y: y, radius: SNAKE_SIZE, sectors: 32,  color: @color)]
    @direction = [:left, :right].sample
    @angle = 0
  end

  def move
    x, y = @body.first.x, @body.first.y
    case @direction
    when :left
      @angle -= 5
    when :right
      @angle += 5
    end
    x += Math.cos(@angle * Math::PI / 180) * 5
    y += Math.sin(@angle * Math::PI / 180) * 5

    @body.unshift(Circle.new(x: x, y: y, radius: SNAKE_SIZE, sectors: 32,  color: @color, z: 10))
  end

  def draws
    @body.each(&:draw)
  end
end

player1 = Player.new('red', WIDTH / 4, HEIGHT / 2)
player2 = Player.new('blue',  (WIDTH / 4) * 2, HEIGHT / 2)

player1.direction = 0
player2.direction = 0

player2_right_pressed = false
player2_left_pressed = false
player1_right_pressed = false
player1_left_pressed = false

on :key_down do |event|
  close if event.key == 'escape'
end

on :key do |event|
  if event.key == 'd' && player1.direction != :left && event.type == :down
    player1_right_pressed = true
  elsif event.key == 'd' && player1.direction != :left && event.type == :up
    player1_right_pressed = false
  elsif event.key == 'a' && player1.direction != :right && event.type == :down
    player1_left_pressed = true
  elsif event.key == 'a' && player1.direction != :right && event.type == :up
    player1_left_pressed = false
  end
end

on :key do |event|
  if event.key == 'right' && player2.direction != :left && event.type == :down
    player2_right_pressed = true
  elsif event.key == 'right' && player2.direction != :left && event.type == :up
    player2_right_pressed = false
  elsif event.key == 'left' && player2.direction != :right && event.type == :down
    player2_left_pressed = true
  elsif event.key == 'left' && player2.direction != :right && event.type == :up
    player2_left_pressed = false
  end
end

update do

  sleep 0.03

  if collision_with_wall(player1) || collision_with_wall(player2)
    close
  end

  if player2_right_pressed
    player2.direction = :right
  elsif player2_left_pressed
    player2.direction = :left
  else
    player2.direction = 0
  end

  if player1_right_pressed
    player1.direction = :right
  elsif player1_left_pressed
    player1.direction = :left
  else
    player1.direction = 0
  end

  player1.move
  player2.move

  if collision(player1, player2)
   close
  end

end

def collision(player1, player2)
  player1_head = player1.body.first
  player2_head = player2.body.first

  # Check if player1's head collides with player2's body
  player2.body[1..-1].each do |segment|
    if distance(player1_head.x, player1_head.y, segment.x, segment.y) <= SNAKE_SIZE * 2
      puts "Player 1 head collided with player 2 body"
      return true
    end
  end

  # Check if player2's head collides with player1's body
  player1.body[1..-1].each do |segment|
    if distance(player2_head.x, player2_head.y, segment.x, segment.y) <= SNAKE_SIZE * 2
      puts "Player 2 head collided with player 1 body"
      return true
    end
  end

  # Check if player1's head collides with its own body
  player1.body[1..-1].each do |segment|
    if distance(player1_head.x, player1_head.y, segment.x, segment.y) <= SNAKE_SIZE * 0.5
      puts "Player 1 head collided with its own body"
      return true
    end
  end

  # Check if player2's head collides with its own body
  player2.body[1..-1].each do |segment|
    if distance(player2_head.x, player2_head.y, segment.x, segment.y) <= SNAKE_SIZE * 0.5
      puts "Player 2 head collided with its own body"
      return true
    end
  end

  false
end

def distance(x1, y1, x2, y2)
  Math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
end

def collision_with_wall(player)
  player_head = player.body.first

  if player_head.x >= WIDTH || player_head.x <= 0
    return true
  end

  if player_head.y >= HEIGHT || player_head.y <= 0
    return true
  end

    false
  end

show