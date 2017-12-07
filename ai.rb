require './evaluator'

class Ai
  MAX_TURN = 60
  INT_MAX = 99999

  def initialize()
    @corner_coordinates = ['A1', 'H1', 'A8', 'H8']
    @presearch_depth = 3
    @normal_depth = 7
    @wld_depth = 15
    @perfect_depth = 13
    @evaluator = MidEvaluator.new
    @begin_time = Time.now().to_i
  end
 
  def negamax_move(board)
    @begin_time = Time.now().to_i
    @evaluator = MidEvaluator.new
    mobility_coordinates_array = board.get_array_movable_pos()
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

    if MAX_TURN - board.get_turn() <= @wld_depth
      limit = INT_MAX
      if MAX_TURN - board.get_turn() <= @perfect_depth
        @evaluator = PerfectEvaluator.new
      else
        @evaluator = WLDEvaluator.new
      end
    else
      limit = @normal_depth
    end
    
    decide_coordinates = mobility_coordinates_array[0]

    alpha = -INT_MAX
    beta = INT_MAX
    
    mobility_coordinates_array.each do |coordinates|
      current_time = Time.now().to_i
      if current_time - @begin_time >= 240
        puts "4分経過したので現在の最善手を打ちます"
        board.put_stone(decide_coordinates)
        return
      end
      board.put_stone(coordinates)
      eval = -negamax(board, limit-1, -beta, -alpha)
      board.undo()
      current_time = Time.now().to_i
      puts "coordinates: #{coordinates}, eval: #{eval}, duration: #{current_time - @begin_time}[sec]"
      if eval > alpha
        alpha = eval
        decide_coordinates = coordinates
      end
    end
    
    puts "AIは #{decide_coordinates} を選択しました"
    board.put_stone(decide_coordinates)  
  end
  
  def sort(board, mobility_coordinates_array, limit)
    evals = []
    ret_mobility_coordinates_array = []
    mobility_coordinates_array.each do |coordinates|
      board.put_stone(coordinates)
      eval = -negamax(board, limit-1, -INT_MAX, INT_MAX)
      board.undo()
      puts "[pre] coordinates: #{coordinates} eval: #{eval}"

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

  def negamax(board, limit, alpha, beta)
    if limit == 0 || board.is_game_end?()
      return @evaluator.evaluate(board)
    end

    mobility_coordinates_array = board.get_array_movable_pos()
    
    if mobility_coordinates_array.length == 0
      board.pass()
      score = -negamax(board, limit, -beta, -alpha)
      board.undo()
      return score
    end

    # 着手可能場所をすべて回す
    mobility_coordinates_array.each do |coordinates|
      board.put_stone(coordinates)
      score = -negamax(board, limit-1, -beta, -alpha)
      board.undo()
      
      if score >= beta
        return score
      end
      
      alpha = [alpha, score].max
    end
    alpha  
  end

end
