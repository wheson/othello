class Ai
  def initialize()
  
  end
  
  def move(board)
    mobility_coordinates_array = board.get_array_movable_pos()

    if mobility_coordinates_array.empty?
      board.pass()
      return
    end

    if mobility_coordinates_array.length() != 0
      board.put_stone(mobility_coordinates_array[0])
      return
    end
  end

  def evaluate(board)

  end

  def sort()

  end

  def alphabeta(board, limit, alpha, beta)
    if board.is_game_end? \
    || limit == 0
      return evaluate(board) 
    end

    mobility_coordinates_array = board.get_array_movable_pos()
    
    if mobility_coordinates_array.empty?
      board.pass()
      score = -alphabeta(board, limit, -beta, -alpha)
      board.undo()
      return score
    end
    for coordinates in mobility_coordinates_array
      board.put_stone(coordinates)
      score = -alphabeta(board, limit-1, -beta, -alpha)
      board.undo()

      if score >= beta
        return score
      end

      alpha = [alpha, score].max
    end
    alpha
  end
end
