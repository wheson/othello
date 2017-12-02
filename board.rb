class Board
  def initialize()
    @white = 0x1008000000
    @black = 0x810000000
    @pre_white = [0x1008000000]
    @pre_black = [0x810000000]
    @turn = 1
    @turn_player = 1
    @player_color = {1 => 'black', -1 => 'white'}
  end
  
  def transfer_point_to_bit(coordinates)
    split_array = coordinates.split("")
    x = split_array[0].upcase.ord - 'A'.ord + 1
    y = split_array[1].ord - '1'.ord + 1
    num = (y - 1) * 8 + (x - 1)
    1 << num
  end

  def transfer_bit_to_point(bit)
    mask = 1
    num = 0
    x = ''
    y = ''
    while mask <= 0x8000000000000000
      if bit & mask != 0
        x = ((num % 8) + 'A'.ord).chr
        y = ((num / 8) + '1'.ord).chr
      end
      num += 1
      mask = mask << 1
    end
    x + y
  end

  def create_reverse_bit(player, enemy, pos)
    rev = 0

    if ((player | enemy) & pos) != 0
      return rev
    end
    
    # 右
    tmp = 0
    mask = (pos >> 1) & 0x7f7f7f7f7f7f7f7f
    while mask != 0 && (mask & enemy) != 0
      tmp |= mask
      mask = (mask >> 1) & 0x7f7f7f7f7f7f7f7f
    end
    if mask & player != 0
      rev |= tmp
    end
    
    # 左
    tmp = 0
    mask = (pos << 1) & 0xfefefefefefefefe
    while mask != 0 && (mask & enemy) != 0
      tmp |= mask
      mask = (mask << 1) & 0xfefefefefefefefe
    end
    if mask & player != 0
      rev |= tmp
    end
    
    # 上
    tmp = 0
    mask = (pos << 8) 
    while mask != 0 && (mask & enemy) != 0
      tmp |= mask
      mask = (mask << 8) 
    end
    if mask & player != 0
      rev |= tmp
    end

    # 下
    tmp = 0
    mask = (pos >> 8) 
    while mask != 0 && (mask & enemy) != 0
      tmp |= mask
      mask = (mask >> 8) 
    end
    if mask & player != 0
      rev |= tmp
    end

    # 右上
    tmp = 0
    mask = (pos << 7) & 0x7f7f7f7f7f7f7f7f
    while mask != 0 && (mask & enemy) != 0 
      tmp |= mask
      mask = (mask << 7) & 0x7f7f7f7f7f7f7f7f
    end
    if mask & player != 0
      rev |= tmp
    end

    # 左上
    tmp = 0
    mask = (pos << 9) & 0xfefefefefefefefe
    while mask != 0 && (mask & enemy) != 0 
      tmp |= mask
      mask = (mask << 9) & 0xfefefefefefefefe
    end
    if mask & player != 0
      rev |= tmp
    end

    # 右下
    tmp = 0
    mask = (pos >> 9) & 0x7f7f7f7f7f7f7f7f
    while mask != 0 && (mask & enemy) != 0 
      tmp |= mask
      mask = (mask >> 9) & 0x7f7f7f7f7f7f7f7f
    end
    if mask & player != 0
      rev |= tmp
    end
    
    # 左下
    tmp = 0
    mask = (pos >> 7) & 0xfefefefefefefefe
    while mask != 0 && (mask & enemy) != 0 
      tmp |= mask
      mask = (mask >> 7) & 0xfefefefefefefefe
    end
    if mask & player != 0 
      rev |= tmp
    end
    
    rev
  end
  
  def put_stone(coordinates)
    pos = transfer_point_to_bit(coordinates)
        
    if @turn_player == 1  
      rev = create_reverse_bit(@black, @white, pos)
      if rev == 0
        return false
      end
      @pre_black.push(@black)
      @pre_white.push(@white)
      @black ^= pos | rev
      @white ^= rev
    else
      rev = create_reverse_bit(@white, @black, pos)
      if rev == 0
        return false
      end
      @pre_black.push(@black)
      @pre_white.push(@white)
      @white ^= pos | rev
      @black ^= rev
    end
    
    next_turn()
    true
  end
  
  def create_movable_pos(player, enemy)
    blank = ~(player | enemy)
    mobility = 0

    # 右
    masked_enemy = enemy & 0x7e7e7e7e7e7e7e7e
    t = masked_enemy & (player << 1)
    ## 5回繰り返す
    5.times{t |= masked_enemy & (t << 1)}
    mobility |= blank & (t << 1)

    # 左
    masked_enemy = enemy & 0x7e7e7e7e7e7e7e7e
    t = masked_enemy & (player >> 1)
    ## 5回繰り返す
    5.times{t |= masked_enemy & (t >> 1)}
    mobility |= blank & (t >> 1)

    # 上
    masked_enemy = enemy & 0x00ffffffffffff00
    t = masked_enemy & (player << 8)
    ## 5回繰り返す
    5.times{t |= masked_enemy & (t << 8)}
    mobility |= blank & (t << 8)
    
    # 下
    masked_enemy = enemy & 0x00ffffffffffff00
    t = masked_enemy & (player >> 8)
    ## 5回繰り返す
    5.times{t |= masked_enemy & (t >> 8)}
    mobility |= blank & (t >> 8)

    # 右上
    masked_enemy = enemy & 0x007e7e7e7e7e7e00
    t = masked_enemy & (player << 7)
    ## 5回繰り返す
    5.times{t |= masked_enemy & (t << 7)}
    mobility |= blank & (t << 7)

    # 左上
    masked_enemy = enemy & 0x007e7e7e7e7e7e00
    t = masked_enemy & (player << 9)
    ## 5回繰り返す
    5.times{t |= masked_enemy & (t << 9)}
    mobility |= blank & (t << 9)

    # 右下
    masked_enemy = enemy & 0x007e7e7e7e7e7e00
    t = masked_enemy & (player >> 9)
    ## 5回繰り返す
    5.times{t |= masked_enemy & (t >> 9)}
    mobility |= blank & (t >> 9)
    
    # 左下
    masked_enemy = enemy & 0x007e7e7e7e7e7e00
    t = masked_enemy & (player >> 7)
    ## 5回繰り返す
    5.times{t |= masked_enemy & (t >> 7)}
    mobility |= blank & (t >> 7)
    
    mobility
  end
  
  def count_stone(counted)
    counted = (counted & 0x5555555555555555) + ((counted & 0xAAAAAAAAAAAAAAAA) >> 1)
    counted = (counted & 0x3333333333333333) + ((counted & 0xCCCCCCCCCCCCCCCC) >> 2)
    counted = (counted & 0x0F0F0F0F0F0F0F0F) + ((counted & 0xF0F0F0F0F0F0F0F0) >> 4)
    counted = (counted & 0x00FF00FF00FF00FF) + ((counted & 0xFF00FF00FF00FF00) >> 8)
    counted = (counted & 0x0000FFFF0000FFFF) + ((counted & 0xFFFF0000FFFF0000) >> 16)
    counted = (counted & 0x00000000FFFFFFFF) + ((counted & 0xFFFFFFFF00000000) >> 32)
  end
  
  def is_game_end()
    if @black | @white == 0xffffffffffffffff \
    || count_stone(@black) == 0 \
    || count_stone(@white) == 0
      true
    else
      false
    end
  end

  def next_turn()
    @turn_player *= -1
    @turn += 1
  end

  def undo()
    if @turn == 1
      return false
    else
      @black = @pre_black.pop
      @white = @pre_white.pop
      @turn_player *= -1
      @turn -= 1
    end
    true
  end

  def pass()
    if count_movable_pos() != 0
      return false
    else
      @pre_black.push(@black)
      @pre_white.push(@white)
    end
    next_turn()
    true
  end
  
  def count_movable_pos()
    if @turn_player == 1
      count_stone(create_movable_pos(@black, @white))
    else
      count_stone(create_movable_pos(@white, @black))
    end
  end 
  
  def get_array_movable_pos()
    if @turn_player == 1
      # black
      mobility = create_movable_pos(@black, @white)
    else
      # white
      mobility = create_movable_pos(@white, @black)
    end
    mask = 1
    coordinates_list = []
    while mask <= 0x8000000000000000
      bit_point = mobility & mask
      if bit_point != 0
        coordinates_list.push(transfer_bit_to_point(bit_point))
      end
      mask = mask << 1
    end
    coordinates_list
  end

  def print_movable_pos()
    p get_array_movable_pos()
  end

  def print_stone()
    mask = 1
    num = 0
    puts "  A B C D E F G H"
    while mask <= 0x8000000000000000
      if mask & 0x0101010101010101 != 0
        print "#{('1'.ord + num).chr} " 
      end
      if @white & mask != 0
        print "o"
      elsif @black & mask != 0
        print "x"
      else
        print "-"
      end
      print " "

      if mask & 0x8080808080808080 != 0
        print "\n"
        num += 1
      end

      mask = mask << 1
    end
  end
  
  def print_info()
    puts "black: #{count_stone(@black)}, white: #{count_stone(@white)}, turn: #{@turn}"
    puts "現在のプレイヤーは #{@player_color[@turn_player]} です"
    print_movable_pos
  end

  def print_result()
    print_stone()
    black_stone = count_stone(@black)
    white_stone = count_stone(@white)
    puts "black: #{black_stone}, white: #{white_stone}"

    if black_stone > white_stone
      puts "black win!"
    elsif black_stone < white_stone
      puts "white win!"
    else
      puts "draw"
    end
  end
end
