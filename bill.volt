METER units; // instead of int
METER rate;
METER energy;
SHOW "Enter units consumed:"; // instead of print
SCAN units; // instead of scanf
SHOW "Enter rate per unit:";
SCAN rate;
energy = units * rate;
CHARGE energy; // add energy charge to bill
CHARGE 50; // fixed charge
REBATE 20; // discount
TAX 5; // 5% tax on bill
TOTALBILL; // print final bill