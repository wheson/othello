require './board.rb'
require './ai.rb'

def select_random(board)
  mobility_coordinates_array = board.get_array_movable_pos()
  
  if mobility_coordinates_array.length == 0
    board.pass()
    return 
  end

  board.put_stone(mobility_coordinates_array[rand(mobility_coordinates_array.length)])
end

if __FILE__ == $0
  ai = Ai.new
  print "対戦回数を入力: "
  vs_num = gets().to_i
  
  ai_win_counts = 0
  ai_draw_counts = 0
  ai_lose_counts = 0

  vs_num.times do |i|
    board = Board.new
    player = i % 2

    while board.is_game_end? == false
      if player == board.get_current_color()
        select_random(board)
      else
        ai.negamax_move(board)
      end
      board.print_stone()
    end

    if board.get_count_stone(player) < board.get_count_stone((player + 1) % 2)
      puts "AI win"
      ai_win_counts += 1
    elsif board.get_count_stone(player) == board.get_count_stone((player + 1) % 2)
      puts "AI draw"
      ai_draw_counts += 1
    else
      puts "AI lose"
      ai_lose_counts += 1
    end
  end
  
  puts "result: win: #{ai_win_counts}, lose: #{ai_lose_counts}, draw: #{ai_draw_counts}"
end
