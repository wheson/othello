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
    @corner_coordinates = ['A1', 'H1', 'A8', 'H8']
    @presearch_depth = 3
    @normal_depth = 7
  end
  
  def evaluate(board, my_color)
    # ゲーム終了しているとき
    if board.is_game_end?()
      # 自石が敵石の数より大きいとき 
      if board.get_count_stone(my_color) > board.get_count_stone((my_color + 1) % 2)
        return 1000
      else
        return -1000
      end
    else
      mask = 1
      sum = 0
      num = 0
      while mask != 0x8000000000000000
        if board.get_board(my_color) & mask != 0
          sum += @score_board[num]  
        end
        if board.get_board((my_color + 1) % 2) & mask != 0
          sum -= @score_board[num]
        end
        mask = mask << 1
        num += 1
      end

      # 着手可能数
      if board.get_current_color() == my_color
        sum += board.count_movable_pos(board.get_current_color())
      else
        sum -= board.count_movable_pos(board.get_current_color())
      end
    end
    sum
  end
  
  def minmax_move(board)
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
    if limit == 0 || board.is_game_end?()
      return evaluate(board, my_color)
    end

    mobility_coordinates_array = board.get_array_movable_pos()
    
    if mobility_coordinates_array.length == 0
      board.pass()
      score = minlevel(board, limit-1, my_color)
      board.undo()
      return score
    end

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
    if limit == 0 || board.is_game_end?()
      return evaluate(board, -my_color)
    end

    mobility_coordinates_array = board.get_array_movable_pos()

    if mobility_coordinates_array.length == 0
      board.pass()
      score = maxlevel(board, limit-1, my_color)
      board.undo()
      return score
    end

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
  
  def negamax_move(board)
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
    
    #角が取れるときは必ず取る
    @corner_coordinates.each do |corner|
      if mobility_coordinates_array.include?(corner)
        board.put_stone(corner)
        return
      end
    end

    limit = 0
    mobility_coordinates_array = sort(board, mobility_coordinates_array, @presearch_depth)

    if MAX_TURN - board.get_turn() <= @normal_depth
      limit = MAX_TURN - board.get_turn()
    else
      limit = @normal_depth
    end
    
    decide_coordinates = mobility_coordinates_array[0]

    alpha = -INT_MAX
    beta = INT_MAX
    
    mobility_coordinates_array.each do |coordinates|
      board.put_stone(coordinates)
      eval = negamax(board, limit-1, alpha, beta, my_color)
      board.undo()
      if eval > alpha
        alpha = eval
        decide_coordinates = coordinates
      end
    end
    
    #puts decide_coordinates
    board.put_stone(decide_coordinates)  
  end
  
  def sort(board, mobility_coordinates_array, limit)
    evals = []
    ret_mobility_coordinates_array = []
    my_color = board.get_current_color()

    mobility_coordinates_array.each do |coordinates|
      board.put_stone(coordinates)
      eval = -negamax(board, limit-1, -INT_MAX, INT_MAX, my_color)
      board.undo()

      if evals.length == 0
        evals.push(eval)
        ret_mobility_coordinates_array.push(coordinates)
      else
        index = 0
        evals.each do |e|
          if e < eval
            break
          end
          index += 1
        end
        evals.insert(index, eval)
        ret_mobility_coordinates_array.insert(index, coordinates)   
      end
    end

    ret_mobility_coordinates_array
  end

  def negamax(board, limit, alpha, beta, my_color)
    if limit == 0 || board.is_game_end?()
      return evaluate(board, my_color)
    end

    mobility_coordinates_array = board.get_array_movable_pos()
    
    if mobility_coordinates_array.length == 0
      board.pass()
      score = -negamax(board, limit, -beta, -alpha, my_color)
      board.undo()
      return score
    end

    # 着手可能場所をすべて回す
    mobility_coordinates_array.each do |coordinates|
      board.put_stone(coordinates)
      score = -negamax(board, limit-1, -beta, -alpha, my_color)
      board.undo()
      
      if score >= beta
        return score
      end
      
      alpha = [alpha, score].max
    end
    alpha  
  end

end
