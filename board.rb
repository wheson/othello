class Board
  def initialize()
    @white = 0x1008000000
    @black = 0x810000000
    @turn = 1
    @turn_player = 1
  end
  
  def transfer_point_to_bit(x, y)
    num = (y - 1) * 8 + (x - 1)
    1 << num
  end

  def transfer_bit_to_point(bit)
    mask = 1
    num = 0
    x = 0
    y = 0
    while mask <= 0x8000000000000000
      if bit & mask != 0
        x = num % 8 + 1
        y = num / 8 + 1
      end
      num += 1
      mask = mask << 1
    end
    [x, y]
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
  
  def put_stone(x, y)
    pos = transfer_point_to_bit(x, y)
    
    if @turn_player == 1  
      rev = create_reverse_bit(@black, @white, pos)
      if rev == 0
        return false
      end
      @black ^= pos | rev
      @white ^= rev
    else
      rev = create_reverse_bit(@white, @black, pos)
      if rev == 0
        return false
      end
      @white ^= pos | rev
      @black ^= rev
    end
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
    && count_stone(@black) == 0 \
    && count_stone(@white) == 0
      true
    else
      false
    end
  end

  def next_turn()
    @turn_player *= -1
    @turn += 1
  end

  def print_movable_pos()
    if @turn_player == 1
      # black
      mobility = create_movable_pos(@black, @white)
    else
      # white
      mobility = create_movable_pos(@white, @black)
    end
    mask = 1
    print "{"
    while mask <= 0x8000000000000000
      point = mobility & mask
      if point != 0
        x, y = transfer_bit_to_point(point)
        print "[#{x}, #{y}],"
      end
      mask = mask << 1
    end
    print "}\n"
  end

  def print_stone()
    mask = 1
    while mask <= 0x8000000000000000
      if @white & mask != 0
        print "●"
      elsif @black & mask != 0
        print "○"
      else
        print "・"
      end
      print " "

      if mask & 0x8080808080808080 != 0
        print "\n"
      end

      mask = mask << 1
    end
    puts "black: #{count_stone(@black)}, white: #{count_stone(@white)}"
  end

  def print_result()

  end
end
