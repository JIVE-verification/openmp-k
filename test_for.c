#include <stdio.h>

int main() {
    int sum = 0;
    for (int i = 1; i < 5; i++) {
        sum += i;
    }
    return sum;
}

/*
Identifier ( "main" ) |-> map ( funLabel ( Identifier ( 
                  "main" ) ) |-> gotoObject ( 0 , .List , pushBlock ~> 
                  enterBlock ( 1 ) ~> CabsLoc ( "test_for.c" , 4 , 5 , 0 )
                   ~> declareInternalVariable ( Identifier ( "sum" ) , t ( 
                  .Set , int ) , initValue ( Identifier ( "sum" ) , t ( .Set
                   , int ) , Computation ( te ( Identifier ( "sum" ) := tv (
                   0 , t ( .Set , int ) ) , t ( .Set , int ) ) ) ) ) ~> 
                  CabsLoc ( "test_for.c" , 5 , 5 , 0 ) ~> pushBlock ~> 
                  enterBlock ( 2 ) ~> CabsLoc ( "test_for.c" , 5 , 10 , 0 )
                   ~> declareInternalVariable ( Identifier ( "i" ) , t ( 
                  .Set , int ) , initValue ( Identifier ( "i" ) , t ( .Set ,
                   int ) , Computation ( te ( Identifier ( "i" ) := tv ( 1 ,
                   t ( .Set , int ) ) , t ( .Set , int ) ) ) ) ) ~> For ( te
                   ( Identifier ( "i" ) < tv ( 5 , t ( .Set , int ) ) != tv 
                  ( 0 , t ( SetItem ( IntegerConstant ) , int ) ) , t ( .Set
                   , int ) ) , te ( postOp ( ncle ( Identifier ( "i" ) , t (
                   .Set , int ) ) , te ( LHOLE := RHOLE + tv ( 1 , t ( .Set 
                  , int ) ) , t ( .Set , int ) ) ) , t ( .Set , int ) ) , 
                  pushBlock ~> enterBlock ( 3 ) ~> CabsLoc ( "test_for.c" , 
                  5 , 33 , 0 ) ~> pushBlock ~> enterBlock ( 4 ) ~> CabsLoc (
                   "test_for.c" , 6 , 9 , 0 ) ~> Computation ( te ( 
                  compoundAssign ( ncle ( Identifier ( "sum" ) , t ( .Set , 
                  int ) ) , te ( LHOLE := RHOLE + Identifier ( "i" ) , t ( 
                  .Set , int ) ) ) , t ( .Set , int ) ) ) ~> exitBlock ( 4 )
                   ~> popBlock ~> exitBlock ( 3 ) ~> popBlock ) ~> exitBlock
                   ( 2 ) ~> popBlock ~> CabsLoc ( "test_for.c" , 8 , 5 , 0 )
                   ~> Return ( te ( Identifier ( "sum" ) , t ( .Set , int ) 
                  ) ) ~> exitBlock ( 1 ) ~> popBlock ~> Return ( tv ( 0 , t 
                  ( .Set , int ) ) ) , .List , .List ) )*/