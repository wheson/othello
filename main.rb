require './board.rb'
require './ai.rb'

def select_player(board)
  next_flag = false
  
  while next_flag == false
    
    print "手を入力してください(e.g. #{board.get_array_movable_pos()[0]}, u: undo, p: pass): "
    coordinates = gets
    if coordinates.ord == 'u'.ord
      2.times{
        next_flag = board.undo()
        if next_flag == false
          puts "これ以上undoできません!"
          break
        else
          puts "undoしました"
        end
      }
    elsif coordinates.ord == 'p'.ord
      next_flag = board.pass()
      if next_flag == false
        puts "passできません!"
      end
    else
      next_flag = board.put_stone(coordinates)
      if next_flag == false
        puts "不正な手です! もう一度入力してください"
      end
    end
  end
end

if __FILE__ == $0
  board = Board.new
  ai = Ai.new
  print "先手後手を選んでください(0: 先手, 0以外: 後手): "
  
  if gets().to_i == 0 
    player = board.get_current_color()
  else
    player = (board.get_current_color() + 1) % 2
  end

  while board.is_game_end? == false
    board.print_stone()
    board.print_info()
    if player == board.get_current_color()
      select_player(board)
    else
      puts "コンピュータが思考中です..."
      ai.minmax_move(board)
    end
  end

  board.print_result()

end
