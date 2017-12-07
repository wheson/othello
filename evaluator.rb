class MidEvaluator
  def initialize()
    @score_board = [
                     50,  -20,   0,  -1,  -1,   0, -20,  50,
                    -20,  -30,  -3,  -3,  -3,  -3, -30, -20,
                      0,   -3,   0,  -1,  -1,   0,  -3,  20,
                     -1,   -3,  -1,  -1,  -1,  -1,  -3,  -1,
                     -1,   -3,  -1,  -1,  -1,  -1,  -3,  -1,
                      0,   -3,   0,  -1,  -1,   0,  -3,  20,
                    -20,  -30,  -3,  -3,  -3,  -3, -30, -20,
                     50,  -20,   0,  -1,  -1,   0, -20,  50
                    ]
  end
  
  def is_corner?(board)
    stone = board.get_board(0) | board.get_board(1)
    if stone & 0x8000000000000000 != 0
      @score_board[1] = 0
      @score_board[8] = 0
      @score_board[9] = 0
    else  
      @score_board[1] = -20
      @score_board[8] = -20
      @score_board[9] = -30
    end
    if stone & 1 != 0
      @score_board[62] = 0
      @score_board[55] = 0
      @score_board[54] = 0
    else  
      @score_board[62] = -20
      @score_board[55] = -20
      @score_board[54] = -30
    end
    if stone & 0x80 != 0
      @score_board[57] = 0
      @score_board[49] = 0
      @score_board[48] = 0
    else  
      @score_board[57] = -20
      @score_board[49] = -30
      @score_board[48] = -20
    end
    if stone & 0x100000000000000 != 0
      @score_board[6] = 0
      @score_board[14] = 0
      @score_board[15] = 0
    else  
      @score_board[6] = -20
      @score_board[14] = -30
      @score_board[15] = -20
    end
  end

  def evaluate(board)
    current_color = board.get_current_color()
    player = board.get_board(current_color)
    enemy = board.get_board(-current_color)
    
    # 角が取られているときはその周辺を変更
    is_corner?(board)

    mask = 1
    sum = 0
    num = 0

    while mask != 0x8000000000000000
      if player & mask != 0
        sum += @score_board[num]  
      end
      if enemy & mask != 0
        sum -= @score_board[num]
      end
      mask = mask << 1
      num += 1
    end

    # 着手可能数
    sum += board.count_movable_pos(current_color) * 5
    #puts "sum: #{sum}"
    #board.print_stone()
    sum
  end
end

class WLDEvaluator
  def initialize()
  end

  def evaluate(board)
    disc_diff = board.get_current_color() * (board.get_count_stone(1) - board.get_count_stone(-1))

    if disc_diff > 0
      return 1
    elsif disc_diff < 0
      return -1
    else 
      return 0
    end
  end
  
end

class PerfectEvaluator
  def initialize()
  end

  def evaluate(board)
    return board.get_current_color() * (board.get_count_stone(1) - board.get_count_stone(-1))
  end
end
