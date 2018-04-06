require_relative 'game'
require_relative 'board'
require_relative 'cell'

puts "What Level Game Do You Want To Start? 'easy', 'medium', 'hard'"
level = gets.chomp.strip
Game.new(level: level).start_game
