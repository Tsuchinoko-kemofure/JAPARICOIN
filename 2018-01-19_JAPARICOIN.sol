pragma solidity ^0.4.18;


//     _____   ______   _______    ______   _______   ______   ______    ______   ______  __    __
//    /     | /      \ /       \  /      \ /       \ /      | /      \  /      \ /      |/  \  /  |
//    $$$$$ |/$$$$$$  |$$$$$$$  |/$$$$$$  |$$$$$$$  |$$$$$$/ /$$$$$$  |/$$$$$$  |$$$$$$/ $$  \ $$ |
//       $$ |$$ |__$$ |$$ |__$$ |$$ |__$$ |$$ |__$$ |  $$ |  $$ |  $$/ $$ |  $$ |  $$ |  $$$  \$$ |
//  __   $$ |$$    $$ |$$    $$/ $$    $$ |$$    $$<   $$ |  $$ |      $$ |  $$ |  $$ |  $$$$  $$ |
// /  |  $$ |$$$$$$$$ |$$$$$$$/  $$$$$$$$ |$$$$$$$  |  $$ |  $$ |   __ $$ |  $$ |  $$ |  $$ $$ $$ |
// $$ \__$$ |$$ |  $$ |$$ |      $$ |  $$ |$$ |  $$ | _$$ |_ $$ \__/  |$$ \__$$ | _$$ |_ $$ |$$$$ |
// $$    $$/ $$ |  $$ |$$ |      $$ |  $$ |$$ |  $$ |/ $$   |$$    $$/ $$    $$/ / $$   |$$ | $$$ |
//  $$$$$$/  $$/   $$/ $$/       $$/   $$/ $$/   $$/ $$$$$$/  $$$$$$/   $$$$$$/  $$$$$$/ $$/   $$/

// Created by Tsuchinoko
// これはっ! ジャパリコインだっ!!


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization
 * control functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the
    * sender account.
    */
    function Ownable() public {
        owner = msg.sender;
    }


    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}

contract BasicJAPARICOIN {
    using SafeMath for uint256;

    // Public variables of the token
    string public constant name = "🐾JAPARICOIN";
    string public constant symbol = "JPR2";
    uint8  public constant decimals = 18;
    // 18 decimals is the strongly suggested default

    uint256 public totalSupply = 126822000201503162017011103;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 value);


    function totalSupply() public view returns (uint256 _totalSupply) {
         return totalSupply;
     }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOf[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowance[_owner][_spender];
    }

    // Internal transfer, only can be called by this contract
    function _transfer(address _from, address _to, uint256 _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        require(_value > 0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to].add(_value) > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
        // Subtract from the sender
        balanceOf[_from] = balanceOf[_from].sub(_value);
        // Add the same to the recipient
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value > 0);
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balanceOf[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balanceOf[burner] = balanceOf[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}



contract JAPARICOIN is Ownable, BasicJAPARICOIN {
    uint256 public buyPrice;
    uint256 public refillPrice;
    uint256 public minBalanceForAccounts;
    uint256 public currentSupply = 0;

    bool public mintingFinished = false;
    bool public buyingFinished = false;

    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    event BuyFinished();


    /**
     * Constrctor function
     */
    function JAPARICOIN(address Tsuchinoko) public {
        owner = Tsuchinoko;
        balanceOf[owner] = totalSupply;
        setPrices(1, 1);  // 1 JPR = 0.00001 ether
        setMinBalance(5); // 5 finney = 0.005 ether
    }

    /**
     * @notice Allow users to buy tokens for `newBuyPrice` eth
     *  　　　and sell tokens for `newRefillPrice` eth
     * @param newBuyPrice Price users can buy from the contract
     * @param newRefillPrice Price the users can sell to the contract
     */
    function setPrices(uint256 newBuyPrice, uint256 newRefillPrice) onlyOwner public {
        buyPrice = newBuyPrice.mul(0.00001 ether);   // Ex. 1 JPR = 0.00002 ether
        refillPrice = newRefillPrice.mul(0.00001 ether); // Ex. 1 JPR = 0.00001 ether
    }

    function setMinBalance(uint minimumBalanceInFinney) onlyOwner public {
        minBalanceForAccounts = minimumBalanceInFinney.mul(1 finney); // 1 finney = 0.001 ether
    }

    /**
     * @notice Function to refill the user balance automatically
     *         as soon as it detects the balance is low to pay a fee.
     */
    function autoRefill(uint256 refillWei) internal {
        require(this.balance >= refillWei);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(refillWei.mul(10**18).div(refillPrice));
        balanceOf[owner] = balanceOf[owner].add(refillWei.mul(10**18).div(refillPrice));
        Transfer(msg.sender, owner, refillWei.mul(10**18).div(refillPrice));
        msg.sender.transfer(refillWei);
    }

    // Internal transfer, only can be called by this contract
    function _transfer(address _from, address _to, uint256 _value) internal {
        // Autorefill
        if(msg.sender.balance < minBalanceForAccounts){
            autoRefill(minBalanceForAccounts.sub(msg.sender.balance));
        }
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        require(_value > 0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to].add(_value) > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
        // Subtract from the sender
        balanceOf[_from] = balanceOf[_from].sub(_value);
        // Add the same to the recipient
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
    }


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }


    modifier canBuy() {
        require(!buyingFinished);
        _;
    }

    /// @notice Buy tokens from contract by sending ether
    function buyTokens() canBuy payable public {
        require(msg.value >= buyPrice);
        uint256 amount = msg.value.mul(10**18).div(buyPrice);
        _transfer(owner, msg.sender, amount);
        currentSupply = currentSupply.add(amount);
    }

    function finishBuying() onlyOwner canBuy public returns (bool) {
        buyingFinished = true;
        BuyFinished();
        return true;
    }


    function withDrawal(uint256 weiAmount) onlyOwner public {
        owner.transfer(weiAmount);
    }

    // fallback function
    function() payable public {
        buyTokens();
     }
}





//                                           ......
//                               ` ..-_::_((_~~~~~~~~____(___..
//                          ` ..(+zttO+:~:>><~~~....~_<:(:<~~~~~~~-.
//                       ..jswXXOttlllz<~>><~~.~~.~._::::~.....~.(<_~-.`
//                   `.(+zwZ0VXZZwttllllz+?<~~~~~.~._::_:~......_::<_(_~_.`
//                   .+zlllwuZXtdZ0ttttlllOI<~~~~~~.~_~~~__....._::~::~_..~~_   `
//                 -+====lllOtwZZ0rttttOwwAAAAwXXXXUUuA&+J--...._~~~__.......~_.
//               (<+tOz?==llltltttwwQkHggmmqkkbWZZuuuzvvrrrXUWa.....``.........~_. `
//             .<+tO1ztz===lllOwQWggggggggmmqqkbpkZuuuzvrrrrtttOVS&.`````` __-__:~_  `
//           .(;;<1lz+ttO?=zzQWggggggggggggmmqqkkbWXuuuzvrrrttttlllvU+..` ~~_~~__..~-
//         .J+>;;;:<1lz<>1uXqmmggggggggmmmmmmmqqkkbpWkuzzvrtttttllll=zVn,.`_~~_......_  ` `
//       `.XwrO+;;;:;;;+uXkkqqmmggggmmH9YYUHkqqmqqkkbpWV777zrttlllll====vn.` ````.....~.
//       .0wXwrrO+;;;<+dbbkkqqqmmmqmHSI<~~_-?Wqqmmqkk6<~~.-`-1tttllll=====Xo.`````..-__~-
//     `.SwZyZZZXwO++jWbbkkkkkqqqqqqSZ?<~~~_-?WqmmmmSl<~~~._ (rrtttlll=====vX,.``.._~~~~~-    `
//   `.StwZ0rwXX0rwXkkkkbkkkkkkkkkHvI?<_~~~~~vqmggHOl<:~~~~~~Ovrrtttlll=====w+`...~~~~~_~.  `
//   .XOttOrrrrrrwWggHkkkbbbkbkkkkHkz??<_:~:~(Wmgg0ttz;;::~~(XXuzvrtttllll===vl` _______.~
//   JIlllltttrrwWgg@ggHkbbppppppbkNy????1++==dggMktttz+++++zpfkXuzvrrttlll===vl`.``......_
//   .0===llltttwXg@ggggggHYY77TWVWpHNy??====lldggMKttrtttttOdkkbfV7<?7OrtttllllO/````.....~_
//  `d1??===llltXgg@g@@gH9I:~~  _?XWpWMmz?===lldggMNOttrrrwwWmmq9I~~~~- ?OrtttlllX-..``......
//  .$>ttrrrvOlwWggggg@gH0I:~~~...(UyfpMNmyzzzdHmggMNmwwXXXgggHSl>::~~~_ (vvrrrttwL..~~~~~__~_
//  JI;ltz1OrZldggggggg@K0tz::~~~~~(XfppbHMMWqqqmmgggMMkHggggHSZt<:::~~~~_wuzzvrrrW--____~::__`
//  X::<zlttI?zXmgggggg@NXrOz<:::~~:(ppppppbbbkkkkqqqmgggggggHXttz;:::::~(XZZuuzvrX{......_~<_
// .R~~::<<;>?zWmmmgggggMkwtrO+;;::::WpppppppppWUUWWbkqqmgggH#Zttlz<;;:++dbWkZZuuudr.......~.~
// .R~~~~:::;>zWqmmmggggHNkwtttOz+++OWWpfffXY>~~~~__~7UbqqmmHNZlltllzzztOWqkkWWyZZX$~~..~.~.~~`
// .R~~~~~:::;1WqqmmmmgmgHMNkwtrtrttwqqHWVC~~~~~~~.~~_ ?4kqmmMNOlttttttAWmmmqqkWWyX$~~~~~~.~.~`
// .R~:~~~~~::+WkqqmmmmmgggMMNmkkwXXmmqH6<:~~~~~~....~...?WqqHMNkwwwwQWgggggmqqkkWWl~~~__~~~~~`
//  W(<>_~~:~:<dbkkqqmmmmmgmgggMMHggmmH6z:~~:~~~~~~.~.~~_(+UkqqmHHHmmgggggggggmmqqKo_(+>>><~~~
//  d<<>>><++<:vpbkkkqqqmmmmgmggggHH96ll=<:~~~~~~~~~~~~~_:;<?TUHqqqmmmggggggggggmmStzwz<_<><~_
//  (r~<<<<<><~<XppbkkkqqqqmmmmmH0z<<<<<+?<:~~~~~~~~~~~_~~~~~~~~?THqmmmggg@g@ggggHVtOwzwz??<~_
//   S_~~~~~~~~~zfpppbbbkkqqqqHXIv::~~_.__<~::~~~~~~~~~~~~~~~~.~_ _?Hqmgggggggg@gSrtttttli_:~`
//   (r~~~~~~~~~(dfppppbbbkkkqXZ=;::~~~~.~~~:::::~~~~~~~~~~~.....~._vkqmmmggggggHZttttttttl+~ `
//   4-~~~~~~~:~<XfppppppbbkNrI?;;::~~~~~~:::::::::~:~:~~~~~~...~~.~WkqmmmmgggHVttttrttttt>`
//   .h~___((<<<:<UffffpppppMRO?><;;;:::::::;;:::::((:~:~~~~~~~~.~~(WkkqqqqqqHZllttttwrttv!
//     (2_;<<<>>><:<XffffpfppWMmyz>???++++z=zwOzzzzzOOz+_~~~~~~~~~~_Jppbkkkkk9I=zuwOtOuZZI! `
//  `  `?o~(;;<<~~~~(vWfffffpfpMMNmAOzzzzwwuXXQQQkkQkkXwzz+(____((+dffpppppW61?=zOwzuuuVv<
//       ?o_<~~~~~~~~:?UVVfffffpppHHMMMWkWqmggggggggmmmqHkkkXkXyyyyVVyVVffUI<>???==lzwVv<
//       ?n_~.~~~~~_(_~?UVVVVfffppppbkqqqmmmgggggggggmmmqqkkbWWyyyyyyyyVC<;;>>???===lz!
//      `  .S-~..~~_;;><(~?4yyyVVVfpppbkkqqmmmmgmgggggggmqqqkkkbWWyyyZVz<:(+lz+???===<!
//           4x~~._;;<<;<~~_<7UyyyVffppbbkqqmmmmmmgmgggggmmqqqkkbbWX6<<::<?=z1Otz==z<`  `
//           (S,(:~~_<~~~~~~~_<7UyyVfppbkkqqqmmmmmgmgggggmmmqqkHUZI1_:~::(1=zztv1<!
//              ?n-~......~~~~~_~~~?7UUWppbkkqqmmmmmmgmmgggHH90Olzzl==1_::::<zv<<!
//               ?n,~~..~..._(;;<_~~~~<<17TUUUWHHHHW99UUOOtltltwuuzOzl=i<::;;<~
//                  ?4+_~.__::<::<~~~~~~((+++;;>>>??=1zzzllllltOuuOOzuXlllz<<`
//                   .7n._<<~::<~.~~~~~><<?=:::;;;>?1rvI==lllltXuXwwuVOAdY'
//                       74+-<<~.~~.~~~>>>??:~::::;;+trI??==llltZVVXXXY!
//                           ?TG+-_~~~~~><<><~~~~~:::<llv>???==zuwXY=`     `
//                               _7TUw+J+<_~<~~~~~~~::?+1++&dVY"!
//                                       ~?7"TTTTTTTY""77!`




// ..~.....................-(>>>>>>;;;;;;;;;;;;;;;;;;;;;;;;>>>>>>>>>>>>>>?>??+-..........~~~~~~~~~~__(~
// .~.._~.~..~.........._(?>>>>>>>;;;;;>;;;;;;;;;;;;;>;>>>>>>>>>>>>>>?>>?>>?????-_...~.~..~~.~~.~~_  (+
// ...~...~~~_.....~~.-JzzOz1<>>>>>;>>;>>>;>>>>>>>>>>>>>>>>>>>>>>>>?>>??>??>?1zOwwo-~..~~._~..~..~~~_(t
// .~......._.......-JC1??>>>>>>>>>>>>>>>>+++??+<+<<+<++1111=1+++???>>?>??????????1O1_..~._~~~.~~~~~:+t
// .~..~.~........_(?????>?>>>>>>>>>+<<>>>>>+>>>>>>>>>>>>?>?>>?>?>?1111z??????????==?1i_..~~~~~~.~~~~(r
// ..............(1???>>>>?>>????>>>>>>>>+<+>>>>>>>>>>>>?>>>>>>>?>>??????z1z?????=?===?=-~~~~..~~.~~~(l
// .~..~..~~_.._J?????>??>??+v<+>>?>>>>>+:<>?>>>>>>>>?>>>?>???>?>???>???????zzzz=?=?=====1_~~~~~.~~~~(t
// ..~...~..~.-+=????1&zzzl1?1;:<<+>?>??>:;1>>?>>??>?????>>?>>????????????????zzzOOOuzz===z-~~~~~~~.~<z
// ..~.......(zzzuZC1?>>?1????<;;;:<<1+?<:::;<<???????>??????????????????==?=?==z=====OVUwAXx~~~~.~~~(z
// ~....~..~(UVC1???>>??>??>??1;:;:;:;;:;;:;;;<?<<<+;+;;;;;<<<++111=zzz======?====?=======lOU+~~~~__~(O
// .~..~..~_O==????????????????z;;;:;;:;:;;:;;;;;;;+;><;;;;;;;;;;;;;;>>>?1z================llZ_~~~._~(t
// ..~..~.(+I===?????????????z<<<;;;;;;;;;;;;;;;;;;z>;z;;;;;;;;;;;;>;>>;>>>1O======z=====l=llzZA.~_~~(r
// .~.~.(wZ0l====?=?1z?????1<;;;>1<;;;;;;;;;;;;;;;>z>>1;>;;;;;><>;>>>;><>>>>>zz=====Oz==l==lllXyyn_~~(w
// ...~(ZyyI======zzI=????z1>>>>;>v1+>;;>;;;;;;;>>+z>>+>>>>>>;>><>>>>>>1>>>>>?+Ol=l==zUAzlllllwyVyn~~(w
// ~.~(ZyySlllzuwX6======v>>>>>;>+<>>>+111+<>>>;>>+>>>j>>>>>>>>>>>>>>>>++>>>????O=l=l=lvUWkAyltXffVl:+w
// .~~dyyV0wdWbV0l======z<>>>>>>>j>>>>>?j>>>>>>>>>+?>>+z>>>>>>>>>z>>>>??z????>??1wllll=llzUHkHmdfffk:(w
// ..(yVVWqkkW6ll=lll=lzI????>???z????>?v?>>>>>>>>j<<<1z><<<<>>>?1??????I???>????zZllll=lllzVHqmHfff<(w
// ~.(VVfHH9Zllll=llZlzZ?????????z<<??<<I????>><(<(:::+I?<::(>???1??????I?????????ZOltllllllltZVHpff>(w
// .~(WVWZtllllllllOllZI=?=??????v+???<+z???????+<(:::?I??<:(????zz=?==zz???????==zOtlwllllllltttXf$:~(
// .~~Jf0tllllllllOItwzI===?=??=z~z====vC==??=???<:::<?????++??==vI====z<v=?======z=XtOOlllllllltwWR:~+
// ~.(WStttlllltttwrwIlI========>`(====v.z======??+++??=??=?====1:+====>`(?=======zlvAywttttlltttttXc:z
// ~~(tttttttttttwkHHllIll=====z!`.Izzzl.1ll===================lc.JzzOz`` z======lzll4gHktttttltltttO(d
// ~_ttttttttttrwd@HSttIllllll=v```(lll{`.OOOl===============OOv``,lll>```(==l=llldltwH@HmOttttlttttwcd
// ~(ttttttttrwd@H9UttOStllllll{````(lll``.llllll=========lllll!``,ll>````.zllllllZOttXZWHHmyttttttttIw
// ~jttttttrAW@HHrr0rtdwtttlllz````.,(OO```,llllllllllllllllll'```(z>(.````1llllltZwttZwrdW@@Hytttttrwd
// ~ztrtrrwd@@MSXrwrrr0wkttttlv`((gMNgmwggMNQstlllllllllllllwmgMMNSd##N(+r`(lllttOOwwtt0rwkH@@HmOrrrrdO
// ~OrrrwdH@H@#wvrwrrdwrXrrttt{ JMH"9YWNM"??!?1lttlllllllllv!~`(M#=_???"""~.tttttwrrXrrXrr0d@@@@@Hmwrww
// ~jmQHHH@HH@SrrvZkrkvrrXrrrt}```` `.#NMa. ```(OZtttttttw>`` .H#He.     `` Otttdrrrwkd0rrrvH@@HH@HH@DO
// ~(MHHHHH@HMXvrrvdkRzzvZkvrt}``   .M#NN#H]  ``,ttttttttO````JMMMMMM.`  `` ZrrwXrrrdHSrrrrrH@HHHHHHM>1
// ~~d@HHHH@@MvrrrrvXM4vzzZkvr}``  `.#HMMqH]` ``jtrrrrrrtw-`  JHkMHHH:`  `` 0rwSvvvvJSvrrrrrZH@H@HH@D;z
// ~_(H@HH@MSvrrrrvvvw-OzzzXTr}``` ` MMKXWH% ``.wrrrrOrrrtl`` ,HSvXH#    ``.Zv(vvvZ~JrrrrtrrrrZHM@@#<<d
// ~~:?MM8Xvrrrrrrrrrvw:juuXl4}``    .WHQWY`  `,rrr7``(zrrO  ` ?HQWY`   ```.v<0vvG(zrrrrrrrrrrrrvvV>_(v
// ~~::?wrrrrrrrrvvvvwmXuuuuXJ ```  `  ``   ```jr7``````(ur;`  `      ``````.zvzzzzWmwvrrrrrrrrrrw>::<+
// ~::~:?XrvrvvvvzwQQHUuuuuzzw:``````````````` <````` ````_>````````````````jvvzuuuuuHMHmyzvvrvvO>:::<z
// ~:~:::?XvzwQQHHHMSZuZuukuuv{```````` ````````````` ````````````````` ```.wzuXkXuuuuXMHHHMmmyZ>:::::d
// ~~::~::~4MH####MZZZXXWWZuuuO.````` ``` ``````````````````````` ``` `````(zuuuuWWWkZZZH###HH@<:;:;;<d
// ~~~~~:~~:dM##NMyyXXUuXZuZuuu;```````` `` ````.,<?<<~_~. ``` ```` `````` zuuuuZZWuuUWXyH##H8;;::;:;+Z
// ~::~~::~~(?M#MyXUuuuXZZZZZZXQ,``````````` ``.:~~~~~~~~~(-`````````````.dHZZZZuZZWzuuXWWHM5;;:;:::~(j
// ~:~~:::~~:~(HWUuuuuXWZZZZZZXXMm.````````````(~~~~~~~~~~~<```````````..H8XkZZZZZZXXuuzuXWn;;:;::::~(d
// ~~~~~~:~:~~(=juuuuuXyyyyyyXSuuXHHJ.`````````.<-_~~~~~~(?~````````..dM8uuzXXyZyyZyRzuuzZ<;>;::;;;;;;d
// :::~~::~::::::?XzuuVyyyyyWSzzuuuuXWHmJ..```````` __~``````` ...JWHUuuzuzuuXWyyyyyWuuX6;;;;;;;;:;;;;d
// ~~:::::~~~~::::?4zuHyVyyWSzuzzzzzuuzzzvvvvzzzzzzvvvvvvvvvvvvvvvzzzzuzzzzzuuXkyyVyWuZ>;;;;;;;;;;:~ (d
// :~~~:::::((<:::::OXHVVVWSuzuuzzzzzzzzzzzzzzzzzzzzzvzzvvzzzzzzzuzzzuzzuuzuzuuXWVVVWD>;;;;;;;;;;;:_ (d
// :::::~:::<~(<~:::;(WffWSuuuuuuuuzzzuzzzzzzzzzzzzzzzvvzzzzzzuzzuuuuzuuuuuuuuZXQHffWz;>;;;;;;;;;;<._(1
// :::::(::::_((:<:::+ffWMNmmQmmmmmQQmQQmmXXuuuuuuuuzzuuuuuuuXXXQQHNNmmQQNMM###MMBUffc;;;;>>;;;;>>>>;<z
// :~:::;:::::;<::;;:jfX<;?TWMM####N###########H#HMM#MMM#H#####NN#NNNNNNNNNUC1????>dfI>>;;;;>>>;;>>><<j
// ::~::(:::(<;;::;:;jV<;::;:;;jgMNNNNNNN####NNNNNNNMNNNNNNNNNNNNNNNMNMMMNNMm+>>>>>>ZI>>;>>>;>;>>>>>>+d
// ::::::;::;+<::;;:;?<;:;;:;;jMNNNNNNN####MMMMMMMMMMMMMMHHMMMMMMNNNNNNNMMMMHZXw&+>>>1>>>>>>>>>>>>???zd
// :::::::;::<<::;;:;;;;;++wuZWMMMMMB9Y7<<::::;?<+v<dMN<1&?1<::;:;<??TTSZZZZuuuuuZk+>>>>>>>>>>>>?????zd
// ::::::;;;:;:;;;;;;;;;jXuuZuuZZZZX<:::::::::++V<;jWfyI;;?A+::::::::;+QQmmQkXZZZZXNz??>>>>>>>>>?>?<+=d
// ;:::;;:::;:;;;;;;;;+dkXyXXQQQQHmmm+:::::++XZ3;;;dZWyy+;:?UXG+<:::;jdNNNNNNNNNNNNNNx??>>>?>?>?>?<<<zw
// :;;;;;::::;;>>;>+>uMNNNNNNMNNNNNNNNe<j&QkZX>;:;jyyWyZk;:;;4QNMNg+jMNMNNNMNNMMMMMNNNz????>???????<_+d
// ;:;;;;;;;;<<>>>>?dMMMMMMNMNNNNNNNMNNNMNNN#>;:;+kyyWyWX2;:;;dNNMMNNMNMMMMMMMNMMMMMMNNz???????????z1+d
