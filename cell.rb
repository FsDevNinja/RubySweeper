class Cell
  attr_accessor :visible, :value, :bomb, :row, :col
  def initialize(row, col, level)
    @visible = false
    @bomb = rand(100) > determine_level(level)
    @value = nil
    @row = row
    @col = col
  end

  def display_value
    return '#' unless visible
    return '*' if bomb
    value.zero? ? ' ' : value.to_s
  end

  def determine_level(level)
    return 90 if level == 'easy'
    return 80 if level == 'medium'
    return 70 if level == 'hard'
    85
  end
end
