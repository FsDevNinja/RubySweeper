class Game
  attr_reader :board, :level
  def initialize(level)
    @board = Board.new(level)
    @level = level
  end

  def start_game
    board.display
    take_turn
  end

  private

  def take_turn
    coords = request_coords
    return invalid_coordinates_error_message unless valid_coords?(coords)
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
        board.display
        take_turn
      end
    end
  end

  def invalid_coordinates_error_message
    puts 'Invalid Coords, Try Again.'
    take_turn
  end

  def request_coords
    puts 'Which one do you want to reveal? ex. row,col'
    gets.chomp.strip.split(',')
  end

  def valid_coords?(coords)
    board.valid_coords.include? [coords.first.to_i, coords.last.to_i]
  end

  def game_over
    board.reveal_cells
    display_ending_for("GameOver.txt")
  end

  def game_won
    board.reveal_cells
    display_ending_for("GameWon.txt")
  end

  def display_ending_for(outcome)
    puts IO.binread(outcome)
    board.display
  end

  def winner?
    board.all_non_bomb_cells_visible?
  end
end
