require './board.rb'

if __FILE__ == $0
  board = Board.new
  while board.is_game_end() == false
    board.print_stone()
    board.print_info()
    next_flag = false
    while next_flag == false
      print "手を入力してください(e.g. #{board.get_array_movable_pos()[0]}, u: undo, p: pass): "
      coordinates = gets
      if coordinates.ord == 'u'.ord 
        next_flag = board.undo()
        if next_flag == false
          puts "これ以上undoできません!"
        else
          puts "undoしました"
        end
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

  board.print_result()

end
