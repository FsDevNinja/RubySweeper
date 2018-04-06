class Board
  attr_accessor :cells_array, :converted_cells, :valid_coords, :row_count, :column_count, :level
  def initialize(level)
    @level = level
    @column_count = 10
    @row_count = 10
    @valid_coords = create_valid_coords
    @cells_array = create_cells_array
    @converted_cells = convert_cells_array_to_values
  end

  def display
    add_padding
    display_header
    display_cells
    add_padding
  end

  def display_header
    puts "    " + (0...column_count).to_a.join(' ')
    puts "   - - - - - - - - - - -"
  end

  def display_cells
    converted_cells.each_with_index do |row, index|
      puts index.to_s + ' | ' + row.map(&:display_value).join(' ')
    end
  end

  def add_padding
    puts "\n\n"
  end

  def reveal_cells
    converted_cells.flatten.each { |cell| cell.visible = true }
  end

  def all_non_bomb_cells_visible?
    converted_cells.flatten.each do |cell|
      return false unless cell.visible || cell.bomb
    end
    true
  end

  def create_valid_coords
    coords = []
    (0...row_count).each do |row|
      (0...column_count).each do |col|
        coords << [row, col]
      end
    end
    coords
  end

  def create_cells_array
    cells_array = []
    (0...row_count).each do |row|
      row_array = []
      (0...column_count).each do |column|
        row_array << Cell.new(row, column, level)
      end
      cells_array << row_array
    end
    cells_array
  end

  def convert_cells_array_to_values
    cells_value_array = []
    cells_array.each_with_index do |row, row_index|
      row_of_cells_array = []
      row.each_with_index do |cell, col_index|
        cell.value =  if cell.bomb
                        9
                      else
                        value = 0
                        surrounding_coords_for(row_index, col_index).each do |coords|
                          value += 1 if cells_array.dig(coords.first, coords.last)&.bomb && valid_coords.include?([coords.first, coords.last])
                        end
                        value
                      end
        row_of_cells_array << cell
      end
      cells_value_array << row_of_cells_array
    end
    cells_value_array
  end

  def reveal_cells_touching_zero(row, col)
    converted_cells.dig(row, col).visible = true
    surrounding_coords_for(row, col).each do |coords|
      if !converted_cells.dig(coords.first, coords.last)&.bomb && valid_coords.include?([coords.first, coords.last])
        if converted_cells.dig(coords.first, coords.last).value.zero? && converted_cells.dig(coords.first, coords.last).visible == false
          reveal_cells_touching_zero(coords.first, coords.last)
        end
        converted_cells.dig(coords.first, coords.last).visible = true
      end
    end
  end

  def surrounding_coords_for(row, col)
    surrounding_coords = []
    surrounding_coords << [row - 1, col]
    surrounding_coords << [row - 1, col - 1]
    surrounding_coords << [row - 1, col + 1]
    surrounding_coords << [row, col + 1]
    surrounding_coords << [row, col - 1]
    surrounding_coords << [row + 1, col]
    surrounding_coords << [row + 1, col - 1]
    surrounding_coords << [row + 1, col +1 ]
    surrounding_coords
  end
end
