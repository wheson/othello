typedef unsigned long long BitBoard;

class Board{
    private:
        BitBoard black;
        BitBoard white;

        Board(){
            black = 0x810000000;
            white = 0x1008000000;
        }
    public:
        BitBoard transfer(BitBoard m);
        BitBoard getRevPat(BitBoard black, BitBoard white, BitBoard putpoint);

    BitBoard transfer(BitBoard m){
        return (m>>1) & 0x7f7f7f7f7f7f7f7f;
    }
    
    BitBoard getRevPat(BitBoard black, BitBoard white, BitBoard putpoint){
        BitBoard rev = 0;
        if( ((black | white) & m) != 0 )  // 着手箇所が空白で無い場合
            return rev;
        BitBoard mask = transfer(m);
        while( mask != 0 && (mask & white) != 0 ) { //  白石が連続する間
            rev |= mask;
            mask = transfer(mask);
        }
        if( (mask & black) == 0 )  //  黒石がなければ、着手できない
            return 0;
        else
            return rev; // 反転パターン
    }
};
