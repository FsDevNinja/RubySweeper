class Game
  attr_reader :board, :level
  def initialize(level: 'easy')
    @board = Board.new(level)
    @level = level
  end

  def display_board
    puts "\n\n"
    puts "    " + (0...board.r).to_a.join(' ')
    puts "   - - - - - - - - - - -"
    board.converted_cells.each_with_index do |row, index|
      mapped_cells = row.map do |cell|
        if cell.bomb && cell.visible
          '*'
        elsif cell.visible
          cell.value.zero? ? ' ' : cell.value.to_s
        else
          '#'
        end
      end
      puts index.to_s + ' | ' + mapped_cells.join(' ')
    end
    puts "\n\n"
  end

  def game_over
    board.converted_cells.flatten.each do |cell|
      cell.visible = true
    end
    data = IO.binread("GameOver.txt")
    puts data
    display_board
  end

  def game_won
    board.converted_cells.flatten.each do |cell|
      cell.visible = true
    end
    data = IO.binread("YouWon.txt")
    puts data
    display_board
  end

  def take_turn
    puts 'Which one do you want to reveal? ex. row,col'
    answer = gets.chomp.strip
    coords = answer.split(',')
    if board.converted_cells.dig(coords.first.to_i, coords.last.to_i).nil?
      puts 'Invalid Coords, Try Again.'
      take_turn
    else
      cell = board.converted_cells.dig(coords.first.to_i, coords.last.to_i)
      if cell.bomb
        game_over
      else
        if cell.value.zero? && cell.visible == false
          board.reveal_cells_touching_zero(cell.row, cell.col)
        end
        cell.visible = true
        if winner?
          game_won
        else
        display_board
        take_turn
        end
      end
    end
  end

  def winner?
    board.converted_cells.flatten.each do |cell|
      return false unless cell.visible || cell.bomb
    end
    true
  end
end

class Board
  attr_accessor :cells_array, :converted_cells, :valid_coords, :r, :level
  def initialize(level)
    @level = level
    @c = 10
    @r = 10
    @valid_coords = create_valid_coords
    @cells_array = create_cells_array
    @converted_cells = convert_cells_array_to_values
  end

  def create_valid_coords
    coords = []
    (0...@r).each do |row|
      (0...@c).each do |col|
        coords << [row, col]
      end
    end
    coords
  end

  def create_cells_array
    cells_array = []
    row_array = []
    (0...@r).each do |row|
      (0...@c).each do |column|
        row_array << Cell.new(row, column, level)
      end
      cells_array << row_array
      row_array = []
    end
    cells_array
  end

  def convert_cells_array_to_values
    cells_value_array = []
    row_of_cells_array = []
    cells_array.each_with_index do |row, ri|
      row.each_with_index do |cell, ci|
        if cell.bomb
          value = 9
        else
          value = 0
          surrounding_coords = create_surrounding_coords(ri, ci)
          surrounding_coords.each do |coords|
            value += 1 if cells_array.dig(coords.first, coords.last)&.bomb && valid_coords.include?([coords.first, coords.last])
          end
        end
        cell.value = value
        row_of_cells_array << cell
      end
       cells_value_array << row_of_cells_array
      row_of_cells_array = []
    end
    cells_value_array
  end

  def reveal_cells_touching_zero(row, col)
    converted_cells.dig(row, col).visible = true
    surrounding_coords = create_surrounding_coords(row, col)
    surrounding_coords.each do |coords|
      if !converted_cells.dig(coords.first, coords.last)&.bomb && valid_coords.include?([coords.first, coords.last])
        if converted_cells.dig(coords.first, coords.last).value.zero? && converted_cells.dig(coords.first, coords.last).visible == false
          reveal_cells_touching_zero(coords.first, coords.last)
        end
        converted_cells.dig(coords.first, coords.last).visible = true
      end
    end
  end

  def create_surrounding_coords(row, col)
    surronding_coords = []
    surronding_coords << [row - 1, col]
    surronding_coords << [row - 1, col - 1]
    surronding_coords << [row - 1, col + 1]
    surronding_coords << [row, col + 1]
    surronding_coords << [row, col - 1]
    surronding_coords << [row + 1, col]
    surronding_coords << [row + 1, col - 1]
    surronding_coords << [row + 1, col +1 ]
    surronding_coords
  end
end

class Cell
  attr_accessor :visible, :value, :bomb, :row, :col
  def initialize(row, col, level)
    @visible = false
    @bomb = rand(100) > determine_level(level)
    @value = nil
    @row = row
    @col = col
  end

  def determine_level(level)
    if level == 'easy'
      90
    elsif level == 'medium'
      80
    elsif level == 'hard'
      70
    else
      85
    end
  end
end
puts "What Level Game Do You Want To Start? 'easy', 'medium', 'hard'"
level = gets.chomp.strip
game = Game.new(level: level)
game.display_board
game.take_turn