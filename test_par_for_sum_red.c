#include <stdio.h>

int main(void)
{
    int sum = 0;
    #pragma omp parallel for reduction(+:sum)
    for (int i = 0; i < 5; i++) {
        sum = sum + i;
    }
    return sum;
}
/*
                Identifier ( "main" ) |-> map ( funLabel ( Identifier ( 
                  "main" ) ) |-> gotoObject ( 0 , .List , pushBlock ~> 
                  enterBlock ( 1 ) ~> CabsLoc ( "test_par_for_sum_red.c" , 5
                   , 5 , 0 ) ~> declareInternalVariable ( Identifier ( "sum"
                   ) , t ( .Set , int ) , initValue ( Identifier ( "sum" ) ,
                   t ( .Set , int ) , Computation ( te ( Identifier ( "sum" 
                  ) := tv ( 0 , t ( .Set , int ) ) , t ( .Set , int ) ) ) ) 
                  ) ~> CabsLoc ( "test_par_for_sum_red.c" , 7 , 5 , 0 ) ~> 
                  pushBlock ~> enterBlock ( 2 ) ~> CabsLoc ( 
                  "test_par_for_sum_red.c" , 7 , 10 , 0 ) ~> 
                  declareInternalVariable ( Identifier ( "i" ) , t ( .Set , 
                  int ) , initValue ( Identifier ( "i" ) , t ( .Set , int ) 
                  , Computation ( te ( Identifier ( "i" ) := tv ( 0 , t ( 
                  .Set , int ) ) , t ( .Set , int ) ) ) ) ) ~> 
                  blockOmpParallelFor ( 1 , BeforeOmp ( 
                  declareInternalVariable ( Identifier ( "sum" ) , t ( .Set 
                  , int ) , initValue ( Identifier ( "sum" ) , t ( .Set , 
                  int ) , Computation ( te ( Identifier ( "sum" ) := tv ( 0 
                  , t ( .Set , int ) ) , t ( .Set , int ) ) ) ) ) ) , 
                  AfterOmp ( Computation ( te ( OmpParentVar ( Identifier ( 
                  "sum" ) ) := OmpParentVar ( Identifier ( "sum" ) ) + 
                  Identifier ( "sum" ) , t ( .Set , int ) ) ) ) , te ( 
                  Identifier ( "i" ) < tv ( 14 , t ( .Set , int ) ) != tv ( 
                  0 , t ( SetItem ( IntegerConstant ) , int ) ) , t ( .Set ,
                   int ) ) , te ( postOp ( ncle ( Identifier ( "i" ) , t ( 
                  .Set , int ) ) , te ( LHOLE := RHOLE + tv ( 1 , t ( .Set ,
                   int ) ) , t ( .Set , int ) ) ) , t ( .Set , int ) ) , 
                  pushBlock ~> enterBlock ( 3 ) ~> interleave ~> CabsLoc ( 
                  "test_par_for_sum_red.c" , 7 , 34 , 0 ) ~> pushBlock ~> 
                  enterBlock ( 4 ) ~> interleave ~> CabsLoc ( 
                  "test_par_for_sum_red.c" , 8 , 9 , 0 ) ~> interleave ~> 
                  Computation ( te ( Identifier ( "sum" ) := Identifier ( 
                  "sum" ) + Identifier ( "i" ) , t ( .Set , int ) ) ) ~> 
                  exitBlock ( 4 ) ~> popBlock ~> exitBlock ( 3 ) ~> popBlock
                   ) ~> exitBlock ( 2 ) ~> popBlock ~> CabsLoc ( 
                  "test_par_for_sum_red.c" , 10 , 5 , 0 ) ~> Return ( te ( 
                  Identifier ( "sum" ) , t ( .Set , int ) ) ) ~> exitBlock (
                   1 ) ~> popBlock ~> Return ( tv ( 0 , t ( .Set , int ) ) )
                   , .List , .List ) )*/