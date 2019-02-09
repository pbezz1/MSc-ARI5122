pragma solidity >=0.4.22 <0.6.0;

contract Tournament {

    struct Punter {                 // structure to hold punter details
        uint8 amount_bet;
        uint8 team_selected;
        bool winner;
    }
    
    uint8 number_of_bets;           // the number of bets placed, should be 10 
    uint8 pot_size;                 // the pot size, should be 100 at the end of the betting
    uint8 winning_team;             // winning team of the tournament, set by organiser
    uint8 bet_size;                 // the size of the bet, set to 10
    uint8 number_of_winners;        // the number of winner participants
    
    uint public current_date;              // current date
    uint public tournament_start_date;     // tournament start date
    uint public tournament_end_date;       // tournament end date

    address payable[] punters;      // array of punters
    address payable[50] winners;    // array of winners

    // address mappings
    mapping(address => Punter) punter_info;    
    mapping(address => Punter) winner_info;    

    address payable owner;          // Owner / organiser of the tournament
    

    // Constructor for contract
    // sets bet_size to 10 and initialise counters
    constructor() public {
        owner = msg.sender;
        bet_size = 10;
        pot_size = 0;
        number_of_bets = 0;
        number_of_winners = 0;
        winning_team = 0;

        current_date = now;
        tournament_start_date = 1548975600;     // Unix timestamp @ 1/2/2019 00:00:00
        tournament_end_date = 1551394799;       // Unix timestamp @ 28/2/2019 23:59:59
    }
    
    function Kill_session() public {
        require(msg.sender == owner,"Only the organiser can kill the session!");
        selfdestruct(owner);
    }
    
    // public function to restart tournament
    function Restart_tournament() public {
        //check if player is organiser
        require(msg.sender == owner,"Only the organiser can set the winning team!");
        
        //check if 28 Feb 2019 has passed, if passed return with message and exit
        require(current_date < tournament_end_date,"Cannot restart tournament after tournament end time!");
        
        //delete punter_info[playerAddress]; // Delete all the players
        punters.length = 0; // Delete all the players array
        pot_size = 0;
        number_of_bets = 0;
        number_of_winners = 0;
    }
    
    // function to set winning team
    function Set_winning_team(uint8 _winning_team) public {
        //check if player is organiser
        require(msg.sender == owner,"Only the organiser can set the winning team!");
        
        //check if 28 Feb 2019 has elapsed, if not return with message and exit
        require(current_date > tournament_end_date,"Cannot set winner before end of competition!");
        
        //check if there are any bets
        require(number_of_bets > 0,"There are no bets yet!");
        
        winning_team = _winning_team;
        SetWinner(_winning_team);
    }
    
    // function to mark who are the winners
    function SetWinner(uint8 _team_winner) private {
        address payable playerAddress;
        uint8 count = 0;      //the count for the array of winners

        //loop through the player array to check who selected the winner team
        for(uint8 i = 0; i < punters.length; i++){
            playerAddress = punters[i];
            //if the player selected the winner team add his address to the winners array
           if(punter_info[playerAddress].team_selected == _team_winner){
                winners[count] = playerAddress;
                count++;
                punter_info[playerAddress].winner = true;
                number_of_winners++;
            }
        }
        number_of_winners = count; 
    }
    
    // function to check if i'm the winner
    function Did_I_win() public view returns(bool) {
        bool bYesWinner = false;
        for(uint256 i = 0; i < winners.length; i++){
            if(winners[i] == msg.sender) bYesWinner = true;
        }
        return bYesWinner;
    }
    
    // public function to return the number of bets placed
    function Show_no_of_bets() public view returns(uint8) {
        return number_of_bets;
    }
    
    // public function to return the amount won
    function How_much_did_I_win() public view returns(uint256) {
        if (winners.length == 0 || Did_I_win() == false) return 0;
        return pot_size / number_of_winners;
    }
    
    // public function to show pot size
    function Show_pot_balance() public view returns(uint8) {
        return pot_size;
    }
    
    // public function to show the number of winners
    function Show_no_of_winners() public view returns(uint8) {
        return number_of_winners;
    }
    
    // function to check if player already placed a bet
    function checkPlayerBet(address payable player) private view returns(bool){
      for(uint256 i = 0; i < punters.length; i++){
         if(punters[i] == player) return true;
      }
      return false;
    }
    
    // public function to place a bet
    function Place_bet(uint8 _team_selected, uint8 _bet_amount) public payable {
        //first check if the date is before 1 Feb 2019, if not return with message and exit
        require(current_date < tournament_start_date,"Cannot place bet now!");
        
        //check that the player hasn't placed a bet already, if yes return with message and exit
        require(!checkPlayerBet(msg.sender),"You already placed a bet!");
        
        //check team number is between 1 and 10
        require(_team_selected >= 1 && _team_selected <= 10,"Team number should be between 1 and 10!");
        
        //validate _bet_amount
        require(_bet_amount == bet_size,"Bet size should be 10!");
      
        //set the player information : amount of the bet and selected team
        punter_info[msg.sender].amount_bet = _bet_amount;
        punter_info[msg.sender].team_selected = _team_selected;
        punter_info[msg.sender].winner = false;
        //then we add the address of the player to the players array
        punters.push(msg.sender);
        
        //place the bet
        pot_size += _bet_amount;
        number_of_bets++;
    }

    // testing : public function to change current_date
    function Make_current_date(uint _unixtimestamp) public returns(uint){
        current_date = _unixtimestamp;
    }
    
    //   1546509600  ==>  3/1/2019 11am
    //   1549274400  ==>  4/2/2019 11am
    //   1551520800  ==>  2/3/2019 11am

}

