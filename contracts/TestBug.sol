
pragma solidity >=0.6.0 <0.7.3;

contract C {
    uint128[] public x;
    
    function voteNumbers() public {
        x.push(100); 
        x.push(42); 
        x.push(42); 
        x.push(42);
    }
    
    
    function fff() public {

        uint128[] memory y = new uint128[](1);
        y[0] = 23;
        // This will shrink the array x to one element.
        x = y;
        // Resizing the array to length 4.
        x.push(); x.push(); x.push();
        
        // After resizing the array, its contents are [23, 0, 0, 42],
        // instead of [23, 0, 0, 0]. Resizing can be also be done by
        // assigning to `.length` or by assigning to the `slot` member
        // inside inline assembly.
    }
}