class Ai
  MAX_TURN = 60
  INT_MAX = 99999

  def initialize()
    @score_board = [
                     30,  -12,   0,  -1,  -1,   0, -12,  30,
                    -12,  -15,  -3,  -3,  -3,  -3, -15, -12,
                      0,   -3,   0,  -1,  -1,   0,  -3,  20,
                     -1,   -3,  -1,  -1,  -1,  -1,  -3,  -1,
                     -1,   -3,  -1,  -1,  -1,  -1,  -3,  -1,
                      0,   -3,   0,  -1,  -1,   0,  -3,  20,
                    -12,  -15,  -3,  -3,  -3,  -3, -15, -12,
                     30,  -12,   0,  -1,  -1,   0, -12,  30
                    ]
    @presearch_depth = 3
    @normal_depth = 6
    @wld_depth = 6
    @perfect_depth = 6
  end
  
  def move(board)
    mobility_coordinates_array = board.get_array_movable_pos()
    my_color = board.get_current_color()
    if mobility_coordinates_array.empty?
      board.pass()
      return
    end

    if mobility_coordinates_array.length() == 1
      board.put_stone(mobility_coordinates_array[0])
      return
    end
    
    limit = 0
    if MAX_TURN - board.get_turn() <= @wld_depth
      limit = MAX_TURN - board.get_turn()
    else
      limit = @normal_depth
    end
    
    decide_coordinates = mobility_coordinates_array[0]

    eval_max = -INT_MAX

    mobility_coordinates_array.each do |coordinates|
      board.put_stone(coordinates)
      eval = minlevel(board, limit-1, my_color)
      board.undo()
      if eval > eval_max
        decide_coordinates = coordinates
      end
    end
    
    #puts decide_coordinates
    board.put_stone(decide_coordinates)
  end
  
  def maxlevel(board, limit, my_color)
    if limit == 0
      return evaluate(board, my_color)
    end

    mobility_coordinates_array = board.get_array_movable_pos()
    
    score_max = -INT_MAX
    mobility_coordinates_array.each do |coordinates|
      board.put_stone(coordinates)
      score = minlevel(board, limit-1, my_color)
      board.undo()
      if score > score_max
        score_max = score
      end
    end

    score_max
  end
  
  def minlevel(board, limit, my_color)
    if limit == 0
      return evaluate(board, -my_color)
    end

    mobility_coordinates_array = board.get_array_movable_pos()

    score_min = INT_MAX
    mobility_coordinates_array.each do |coordinates|
      board.put_stone(coordinates)
      score = maxlevel(board, limit-1, my_color)
      board.undo()
      if score_min > score
        score_min = score
      end
    end

    score_min
  end

  def evaluate(board, my_color)
    mask = 1
    sum = 0
    num = 0
    while mask != 0x8000000000000000
      if board.get_board(my_color) & mask != 0
        sum += @score_board[num]  
      end
      if board.get_board(-my_color) & mask != 0
        sum -= @score_board[num]
      end
      mask = mask << 1
      num += 1
    end
    sum
  end

end
