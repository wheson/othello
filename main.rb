require './board.rb'
require './ai.rb'

def select_player(board)
  board.print_stone()
  board.print_info()
  next_flag = false
  
  while next_flag == false
    
    print "手を入力してください(e.g. #{board.get_array_movable_pos()[0]}, u: undo, p: pass): "
    coordinates = gets
    if coordinates.ord == 'u'.ord
      2.times{
        undo_flag = board.undo()
        if undo_flag == false
          puts "これ以上undoできません!"
          break
        else
          puts "undoしました"
        end
      }
      board.print_stone()
      board.print_info()
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
  print "先手後手を選んでください(1: 先手, 1以外: 後手): "
  
  if gets().to_i == 1
    player = 1
  else
    player = -1
  end

  while board.is_game_end? == false
    if player == 1
      select_player(board)
    else
      ai.move(board)
    end
    player *= -1
  end

  board.print_result()

end
