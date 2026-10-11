module C-STMT-LOOP
     imports C-ABSTRACT-SYNTAX
     imports C-DYNAMIC-SYNTAX
     imports C-ELABORATOR-SYNTAX
     imports C-ENV-SYNTAX
     imports C-EXPR-LOGICAL-SYNTAX
     imports C-PROCESS-LABEL-SYNTAX
     imports C-SYNTAX

     imports COMPAT-SYNTAX

     // This is a little subtle. If the first expression is a declaration, it
     // must be evaluated at the same scope as the for (and not in a nested
     // block) for the purposes of detecting conflicts with other declarations,
     // but it behaves as though it were in a nested block otherwise.
     rule (.K => elaborate(E1)) ~> For(_, E1:K, _, _, _)
     rule elaborateDone(E1:K) ~> For(Tag:BlockTag, _, E2:K, E3:K, B:K)
          => Block(Tag, list(ListItem(E1) ListItem(For(E2, E3, B))))

     // for(int i=0; i< N; i++){} E1:: int i=0; // for(int i=0; i< N; i++){B} For(E1; E2; E3){B}
     rule (.K => elaborate(E1)) ~> OmpParallelFor(_, _, E1:K, _, _, _)

     // for(int i=0; i< N; i++){} E1:: int i=0; // for(int i=0; i< N; i++){B} For(E1; E2; E3){B}
     rule <k> elaborateDone(E1:K)~> OmpParallelFor(Tag:BlockTag, list(OMP1:List), _, E2:K, E3:K, B:K)
               => Block(Tag, list(ListItem(E1) ListItem(blockOmpParallelFor(parseNumThreads(OMP1, TT), BeforeOmp(handleOmpClausesForBeforeOmp(OMP1, M)), AfterOmp(handleOmpClausesForAfterOmp(OMP1, M)), E2, E3, B))))
     	...</k>
     <omp-default-threads> TT:Int </omp-default-threads>
     <types> M:Map </types>

     rule <k> OmpParallel(Tag:BlockTag, list(OMP1:List), S:K)
              => Block(Tag, list(ListItem(blockOmpParallel(parseNumThreads(OMP1, TT), BeforeOmp(handleOmpClausesForBeforeOmp(OMP1, M)), AfterOmp(handleOmpClausesForAfterOmp(OMP1, M)), S))))
     	...</k>
     <omp-default-threads> TT:Int </omp-default-threads>
     <types> M:Map </types>

     // This is the first child of the for if it's not a declaration.
     rule ForClauseExpression(K:K) => Computation(K)

     context For((HOLE => reval(HOLE)), _, _) [result(RValue)]
     context For(_, (HOLE => reval(HOLE)), _) [result(RValue)]
     
     context blockOmpParallelFor(_, _, _, (HOLE => reval(HOLE)), _, _) [result(RValue)]
     context blockOmpParallelFor(_, _, _, _, (HOLE => reval(HOLE)), _) [result(RValue)]    

     rule For(Control:RValue, Post:RValue, S:K)
          => #for(simplifyTruth(Control), Post, S)
          requires Control =/=K emptyValue
     rule For(emptyValue, Post:RValue, S:K)
          => #for(emptyValue, Post, S)

     rule blockOmpParallelFor(Th:Int, B:K, A:K, Control:RValue, Post:RValue, S:K)
          => #blockOmpParallelFor(Th, B, A, simplifyTruth(Control), Post, S)
          requires Control =/=K emptyValue

     rule blockOmpParallelFor(Th:Int, B:K, A:K, emptyValue, Post:RValue, S:K)
          => #blockOmpParallelFor(Th, B, A, emptyValue, Post, S)

     rule blockOmpParallel(Th:Int, B:K, A:K, S:K)
            => #blockOmpParallel(Th, B, A, S)

     syntax KItem ::= #for(K, RValue, K)
     syntax KItem ::= #blockOmpParallel(Int, K, K, K) 
     syntax KItem ::= #blockOmpParallelFor(Int, K, K, K, RValue, K) 
     
     context #for((HOLE => reval(HOLE)), _, _) [result(RValue)]
     context #blockOmpParallelFor(_, _, _, (HOLE => reval(HOLE)), _, _) [result(RValue)]

     rule (.K => elaborate(S)) ~> #for(_:RValue, _, S:K)
     rule <k> elaborateDone(S:K)
               ~> #for(Control:RValue, Post:RValue, _)
               => .K
          ...</k>
          <elab>... .K => For(Control, Post, S) </elab>


     rule (.K => elaborate(S)) ~> #blockOmpParallelFor(_, _, _, _:RValue, _, S:K)
     rule <k> elaborateDone(S:K)
               ~> #blockOmpParallelFor(Th:Int, B:K, A:K, Control:RValue, Post:RValue, _)
               => .K
          ...</k>
          <elab>... .K => blockOmpParallelFor(Th, B, A, Control, Post, putInterleavePointsAsStatements(.K, S)) </elab>


     rule (.K => elaborate(S)) ~> #blockOmpParallel(Th:Int, B:K, A:K, S:K)
     rule <k> elaborateDone(S:K)
               ~> #blockOmpParallel(Th:Int, B:K, A:K,  _)
               => .K
          ...</k>
          <elab>... .K => blockOmpParallel(Th, B, A, putInterleavePointsAsStatements(.K, S)) </elab>
          
     context While((HOLE => reval(HOLE)), _) [result(RValue)]
     rule While(B:RValue, S:K) => #while(simplifyTruth(B), S)

     syntax KItem ::= #while(K, K)
     context #while((HOLE => reval(HOLE)), _) [result(RValue)]

     rule (.K => elaborate(S)) ~> #while(_:RValue, S:K)
     rule <k> elaborateDone(S:K) ~> #while(B:RValue, _) => .K ...</k>
          <elab>... .K => While(B, S) </elab>

     context DoWhile((HOLE => reval(HOLE)), _) [result(RValue)]
     rule DoWhile(B:RValue, S:K) => #doWhile(simplifyTruth(B), S)

     syntax KItem ::= #doWhile(K, K)
     context #doWhile((HOLE => reval(HOLE)), _) [result(RValue)]

     rule (.K => elaborate(S)) ~> #doWhile(_:RValue, S:K)
     rule <k> elaborateDone(S:K) ~> #doWhile(B:RValue, _) => .K ...</k>
          <elab>... .K => DoWhile(B, S) </elab>

     rule <k> Continue => .K ...</k>
          <elab>... .K => Continue </elab>
     
     rule <k> interleave => .K ...</k>
          <elab>... .K => interleave </elab>

     /*********************************
     * Parsing number of threads      *
     **********************************/

     syntax Int ::= getNumThreads(K) [function]
     rule getNumThreads(OmpNumThreads(N:Int)) => N -Int 1
     requires N >=Int 1

     rule getNumThreads(OmpNumThreads(N:Int)) => 0
     requires N <=Int 0

     syntax Int ::= parseNumThreads(List, Int) [function]

     rule parseNumThreads(ListItem(K1:K) L:List, T:Int) => parseNumThreads(L, T)
     requires getKLabel(K1) =/=KLabel 'OmpNumThreads
     
     rule parseNumThreads(ListItem(K1:K) L:List, T:Int) => getNumThreads(K1)
     requires getKLabel(K1) ==KLabel 'OmpNumThreads
     
     rule parseNumThreads(.List, T:Int) => T

     /***********************************
     * Handling OMP Clauses - BEFORE    *
     ************************************/
     syntax K ::= handleOmpClausesForBeforeOmp(List, Map) [function]

     rule handleOmpClausesForBeforeOmp(.List, M:Map) => .K 

     rule handleOmpClausesForBeforeOmp(ListItem(OmpPrivateList(list(L1:List))) L:List, M:Map) => handlePrivateClasueBefore(L1, M) ~> handleOmpClausesForBeforeOmp(L,M)

     rule handleOmpClausesForBeforeOmp(ListItem(OmpFirstPrivateList(list(L1:List))) L:List, M:Map) => handleFirstPrivateClauseBefore(L1, M) ~> handleOmpClausesForBeforeOmp(L,M)

     rule handleOmpClausesForBeforeOmp(ListItem(OmpReduction(S1:String, S2:String, list(L1:List))) L:List, M:Map) => handleReductionClausePlusBefore(L1, M) ~> handleOmpClausesForBeforeOmp(L,M)
     requires S2 ==String "+"

     rule handleOmpClausesForBeforeOmp(ListItem(OmpReduction(S1:String, S2:String, list(L1:List))) L:List, M:Map) => handleReductionClauseProdBefore( L1, M) ~> handleOmpClausesForBeforeOmp(L,M)
     requires S2 ==String "*"

     rule handleOmpClausesForBeforeOmp(ListItem(OmpNumThreads(N:Int)) L:List, M:Map) => handleOmpClausesForBeforeOmp(L,M)

     /*****************************
     * Helper Function - Before
     *****************************/

     syntax K ::= handlePrivateClasueBefore(List, Map) [function]
     syntax K ::= handleFirstPrivateClauseBefore(List, Map) [function]
     syntax K ::= handleReductionClausePlusBefore(List, Map) [function]
     syntax K ::= handleReductionClauseProdBefore(List, Map) [function]     

     rule handlePrivateClasueBefore(.List, M:Map) => .K
     rule handleFirstPrivateClauseBefore(.List, M:Map) => .K
     rule handleReductionClausePlusBefore(.List, M:Map) => .K
     rule handleReductionClauseProdBefore(.List, M:Map) => .K

     rule handlePrivateClasueBefore(ListItem(X:CId) L:List, M:Map) =>  declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), .K)) ~> handlePrivateClasueBefore(L, M)
     requires (X in keys(M))


     rule handleFirstPrivateClauseBefore(ListItem(X:CId) L:List, M:Map) =>  declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), Computation(te(X := OmpParentVar(X), type(M[X]))))) ~> handleFirstPrivateClauseBefore(L, M)
     requires (X in keys(M))

     rule handleReductionClausePlusBefore(ListItem(X:CId) L:List, M:Map) =>  declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), Computation(te(X := tv(0, type(M[X])), type(M[X]))))) ~> handleReductionClausePlusBefore(L, M)
     requires (X in keys(M))
     
     rule handleReductionClauseProdBefore(ListItem(X:CId) L:List, M:Map) =>  declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), Computation(te(X := tv(1, type(M[X])), type(M[X]))))) ~> handleReductionClauseProdBefore(L, M)
     requires (X in keys(M))

     /*************************
     * Handling OMP Clauses - After
     **************************/
     syntax K ::= handleOmpClausesForAfterOmp(List, Map) [function]
     // Terminate if empty List
     rule handleOmpClausesForAfterOmp(.List, M:Map) => .K 
     // ignore if private()
     rule handleOmpClausesForAfterOmp(ListItem(OmpPrivateList(list(L1:List))) L:List, M:Map) => handleOmpClausesForAfterOmp(L,M)
     // ignore if firstprivate()
     rule handleOmpClausesForAfterOmp(ListItem(OmpFirstPrivateList(list(L1:List))) L:List, M:Map) =>  handleOmpClausesForAfterOmp(L,M)
     rule handleOmpClausesForAfterOmp(ListItem(OmpReduction(S1:String, S2:String, list(L1:List))) L:List, M:Map) => handleReductionClausePlusAfter(L1, M) ~> handleOmpClausesForAfterOmp(L,M)
     requires S2 ==String "+"
     // add computation if reduction
     rule handleOmpClausesForAfterOmp(ListItem(OmpReduction(S1:String, S2:String, list(L1:List))) L:List, M:Map) => handleReductionClauseProdAfter( L1, M) ~> handleOmpClausesForAfterOmp(L,M)
     requires S2 ==String "*"
     // ignore if rnum_threads()     
     rule handleOmpClausesForAfterOmp(ListItem(OmpNumThreads(N:Int)) L:List, M:Map) => handleOmpClausesForAfterOmp(L,M)
     
     /*****************************
     * Helper Function - After
     *****************************/
     syntax K ::= handleReductionClausePlusAfter(List, Map) [function]
     syntax K ::= handleReductionClauseProdAfter(List, Map) [function]

     rule handleReductionClausePlusAfter(.List, M:Map) => .K
     rule handleReductionClauseProdAfter(.List, M:Map) => .K

      // add plus computation
     rule handleReductionClausePlusAfter(ListItem(X:CId) L:List, M:Map) =>  Computation(te( OmpParentVar(X) := OmpParentVar(X) + X, type(M[X]))) ~> handleReductionClausePlusAfter(L, M)
     requires (X in keys(M))
     // add product computation
     rule handleReductionClauseProdAfter(ListItem(X:CId) L:List, M:Map) =>  Computation(te( OmpParentVar(X) := OmpParentVar(X) * X, type(M[X]))) ~> handleReductionClauseProdAfter(L, M)
     requires (X in keys(M))

     // IF A DOES NOT EXIST
     /**
     rule handlePrivateClasueBefore(ListItem(X:CId) L:List, M:Map) =>  IMPL("JIVE1", "PRIVATE:: Variable is not declared.") ~> handlePrivateClasueBefore(L, M)
     requires notBool (X in keys(M))
     
     rule handleFirstPrivateClauseBefore(ListItem(X:CId) L:List, M:Map) =>  IMPL("JIVE1", "FIRSTPRIVATE:: Variable is not declared.") ~> handleFirstPrivateClauseBefore(L, M)
     requires notBool (X in keys(M)) 

     rule handleLastPrivateClause(ListItem(X:CId) L:List, M:Map) =>  IMPL("JIVE1", "FIRSTPRIVATE:: Variable is not declared.") ~> handleLastPrivateClause(L, M)
     requires notBool (X in keys(M))  
     
     rule handleReductionClausePlus(ListItem(X:CId) L:List, M:Map) =>  IMPL("JIVE1", "FIRSTPRIVATE:: Variable is not declared.") ~> handleLastPrivateClause(L, M)
     requires notBool (X in keys(M))          

     rule handleReductionClauseProd(ListItem(X:CId) L:List, M:Map) =>  IMPL("JIVE1", "FIRSTPRIVATE:: Variable is not declared.") ~> handleLastPrivateClause(L, M)
     requires notBool (X in keys(M))          
     */


     syntax List ::= putInterleavePointsAsList(List, List)[function]

     rule putInterleavePointsAsList(.List, .List) => .List
     rule putInterleavePointsAsList(.List, ListItem(CodeLoc(Cm:Statement, Ln:CabsLoc))) => putInterleavePointsAsList(ListItem(CodeLoc(interleave, Ln)) ListItem(CodeLoc(Cm,Ln)) , .List)
     rule putInterleavePointsAsList(.List, ListItem(CodeLoc(Cm:Statement, Ln:CabsLoc)) L2:List) => putInterleavePointsAsList(ListItem(CodeLoc(interleave, Ln)) ListItem(CodeLoc(Cm,Ln)), L2)
     rule putInterleavePointsAsList(L1:List, ListItem(CodeLoc(Cm:Statement, Ln:CabsLoc)) L2:List) => putInterleavePointsAsList(L1 ListItem(CodeLoc(interleave, Ln)) ListItem(CodeLoc(Cm,Ln)) , L2)
     rule putInterleavePointsAsList(L1:List, ListItem(CodeLoc(Cm:Statement, Ln:CabsLoc))) => putInterleavePointsAsList(L1 ListItem(CodeLoc(interleave, Ln)) ListItem(CodeLoc(Cm,Ln)), .List)
     rule putInterleavePointsAsList(L1:List, .List) => L1


     syntax K ::= putInterleavePointsAsStatements(K, K)[function]

     rule putInterleavePointsAsStatements(.K, .K) => .K
     rule putInterleavePointsAsStatements(.K, K1:KItem) => putInterleavePointsAsStatements(interleave ~> K1, .K)
     requires notBool (K1 ==K pushBlock orBool K1 ==K popBlock orBool getKLabel(K1) ==KLabel 'enterBlock orBool getKLabel(K1) ==KLabel 'exitBlock)

     rule putInterleavePointsAsStatements(.K, K1:KItem) => putInterleavePointsAsStatements(K1, .K)
     requires (K1 ==K pushBlock orBool K1 ==K popBlock orBool getKLabel(K1) ==KLabel 'enterBlock orBool getKLabel(K1) ==KLabel 'exitBlock)

     rule putInterleavePointsAsStatements(.K, K1:KItem ~> T:K) => putInterleavePointsAsStatements(interleave ~> K1, T)
     requires notBool (K1 ==K pushBlock orBool K1 ==K popBlock orBool getKLabel(K1) ==KLabel 'enterBlock orBool getKLabel(K1) ==KLabel 'exitBlock)
     rule putInterleavePointsAsStatements(K1:K, K2:KItem ~> T:K) => putInterleavePointsAsStatements(K1 ~> interleave ~> K2, T)
     requires notBool (K2 ==K pushBlock orBool K2 ==K popBlock orBool getKLabel(K2) ==KLabel 'enterBlock orBool getKLabel(K2) ==KLabel 'exitBlock)
     rule putInterleavePointsAsStatements(K1:K, K2:KItem) => putInterleavePointsAsStatements(K1 ~> interleave ~> K2, .K)
     requires notBool (K2 ==K pushBlock orBool K2 ==K popBlock orBool getKLabel(K2) ==KLabel 'enterBlock orBool getKLabel(K2) ==KLabel 'exitBlock)

     rule putInterleavePointsAsStatements(.K, K1:KItem ~> T:K) => putInterleavePointsAsStatements(K1, T)
     requires  (K1 ==K pushBlock orBool K1 ==K popBlock orBool getKLabel(K1) ==KLabel 'enterBlock orBool getKLabel(K1) ==KLabel 'exitBlock)
     rule putInterleavePointsAsStatements(K1:K, K2:KItem ~> T:K) => putInterleavePointsAsStatements(K1 ~>  K2, T)
     requires  (K2 ==K pushBlock orBool K2 ==K popBlock orBool getKLabel(K2) ==KLabel 'enterBlock orBool getKLabel(K2) ==KLabel 'exitBlock)
     rule putInterleavePointsAsStatements(K1:K, K2:KItem) => putInterleavePointsAsStatements(K1 ~> K2, .K)
     requires  (K2 ==K pushBlock orBool K2 ==K popBlock orBool getKLabel(K2) ==KLabel 'enterBlock orBool getKLabel(K2) ==KLabel 'exitBlock)

     rule putInterleavePointsAsStatements(K1:K, .K) => K1
endmodule
