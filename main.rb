require './board.rb'

if __FILE__ == $0
  board = Board.new

  while(board.is_game_end == false)
    board.print_stone()
    board.print_info()
    
    print "手を入力してください: "
    coordinate = gets

    next_flag = board.put_stone(coordinate)
    
    if next_flag
      board.next_turn()
    else
      puts "不正な手です! もう一度入力してください"
    end
  end

  board.print_result()

end
