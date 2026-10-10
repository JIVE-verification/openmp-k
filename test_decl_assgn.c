#include <stdio.h>
int main(void)
{
    int i = 5;
    i++;
    int j = i;
    j++;
    return i * j;
}

/*
Identifier ( "main" ) |-> map ( funLabel ( Identifier ( 
                  "main" ) ) |-> gotoObject ( 0 , .List , pushBlock ~> 
                  enterBlock ( 1 ) ~> CabsLoc ( "test3.c" , 4 , 5 , 0 ) ~> 
                  declareInternalVariable ( Identifier ( "i" ) , t ( .Set , 
                  int ) , initValue ( Identifier ( "i" ) , t ( .Set , int ) 
                  , Computation ( te ( Identifier ( "i" ) := tv ( 5 , t ( 
                  .Set , int ) ) , t ( .Set , int ) ) ) ) ) ~> CabsLoc ( 
                  "test3.c" , 5 , 5 , 0 ) ~> Computation ( te ( postOp ( 
                  ncle ( Identifier ( "i" ) , t ( .Set , int ) ) , te ( 
                  LHOLE := RHOLE + tv ( 1 , t ( .Set , int ) ) , t ( .Set , 
                  int ) ) ) , t ( .Set , int ) ) ) ~> CabsLoc ( "test3.c" , 
                  6 , 5 , 0 ) ~> declareInternalVariable ( Identifier ( "j" 
                  ) , t ( .Set , int ) , initValue ( Identifier ( "j" ) , t 
                  ( .Set , int ) , Computation ( te ( Identifier ( "j" ) := 
                  Identifier ( "i" ) , t ( .Set , int ) ) ) ) ) ~> CabsLoc (
                   "test3.c" , 7 , 5 , 0 ) ~> Computation ( te ( postOp ( 
                  ncle ( Identifier ( "j" ) , t ( .Set , int ) ) , te ( 
                  LHOLE := RHOLE + tv ( 1 , t ( .Set , int ) ) , t ( .Set , 
                  int ) ) ) , t ( .Set , int ) ) ) ~> CabsLoc ( "test3.c" , 
                  8 , 5 , 0 ) ~> Return ( te ( Identifier ( "i" ) * 
                  Identifier ( "j" ) , t ( .Set , int ) ) ) ~> exitBlock ( 1
                   ) ~> popBlock ~> Return ( tv ( 0 , t ( .Set , int ) ) ) ,
                   .List , .List ) )
*/