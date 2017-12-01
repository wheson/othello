require './board.rb'

if __FILE__ == $0
  board = Board.new
  board.print_stone()

  while(board.is_game_end == false)
    board.print_movable_pos()
    
    print "手を入力してください: "
    x = gets.to_i
    y = gets.to_i

    board.put_stone(x, y)

    board.print_stone()
    board.next_turn()
  end

  board.print_result()

end
