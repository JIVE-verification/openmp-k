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

     // #pragma omp parallel [clauses]{[statements]} 
     rule <k> OmpParallel(Tag:BlockTag, list(OMP1:List), S:K)
              => Block(Tag, list(ListItem(blockOmpParallel(parseNumThreads(OMP1, TT), BeforeOmp(handleOmpClausesForBeforeOmp(OMP1, M)), AfterOmp(handleOmpClausesForAfterOmp(OMP1, M)), S))))
     	...</k>
     <omp-default-threads> TT:Int </omp-default-threads>
     <types> M:Map </types>

     // This is the first child of the for if it's not a declaration.
     rule ForClauseExpression(K:K) => Computation(K)

     context For((HOLE => reval(HOLE)), _, _) [result(RValue)]
     context For(_, (HOLE => reval(HOLE)), _) [result(RValue)]

     rule For(Control:RValue, Post:RValue, S:K)
          => #for(simplifyTruth(Control), Post, S)
          requires Control =/=K emptyValue
     rule For(emptyValue, Post:RValue, S:K)
          => #for(emptyValue, Post, S)

     rule blockOmpParallel(Th:Int, B:K, A:K, S:K)
            => #blockOmpParallel(Th, B, A, S)

     syntax KItem ::= #for(K, RValue, K)
     syntax KItem ::= #blockOmpParallel(Int, K, K, K)  
     
     context #for((HOLE => reval(HOLE)), _, _) [result(RValue)]

     rule (.K => elaborate(S)) ~> #for(_:RValue, _, S:K)
     rule <k> elaborateDone(S:K)
               ~> #for(Control:RValue, Post:RValue, _)
               => .K
          ...</k>
          <elab>... .K => For(Control, Post, S) </elab>

     rule (.K => elaborate(S)) ~> #blockOmpParallel(Th:Int, B:K, A:K, S:K)

     rule <k> elaborateDone(S:K)
               ~> #blockOmpParallel(Th:Int, B:K, A:K,  _)
               => .K
          ...</k>
          <elab>... .K => blockOmpParallel(Th, B, A, S) </elab>
          
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

//     syntax Bool ::= isOmpNumThreads(K) [function]
//     rule isOmpNumThreads(OmpNumThreads(N:Int)) => true
//     rule isOmpNumThreads(_) => false [owise]

     syntax K ::= handleOmpClausesForBeforeOmp(List, Map) [function]

     rule handleOmpClausesForBeforeOmp(.List, M:Map) => .K 

     rule handleOmpClausesForBeforeOmp(ListItem(OmpPrivateList(list(L1:List))) L:List, M:Map) => handlePrivateClasueBefore(L1, M) ~> handleOmpClausesForBeforeOmp(L,M)

     rule handleOmpClausesForBeforeOmp(ListItem(OmpNumThreads(N:Int)) L:List, M:Map) => handleOmpClausesForBeforeOmp(L,M)

     syntax K ::= handlePrivateClasueBefore(List, Map) [function]
     rule handlePrivateClasueBefore(.List, M:Map) => .K
     rule handlePrivateClasueBefore(ListItem(X:CId) L:List, M:Map) =>  declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), .K)) ~> handlePrivateClasueBefore(L, M)
     requires (X in keys(M))

     syntax K ::= handleOmpClausesForAfterOmp(List, Map) [function]
     // Terminate if empty List
     rule handleOmpClausesForAfterOmp(.List, M:Map) => .K 
     // ignore if private()
     rule handleOmpClausesForAfterOmp(ListItem(OmpPrivateList(list(L1:List))) L:List, M:Map) => handleOmpClausesForAfterOmp(L,M)
     // ignore if rnum_threads()     
     rule handleOmpClausesForAfterOmp(ListItem(OmpNumThreads(N:Int)) L:List, M:Map) => handleOmpClausesForAfterOmp(L,M)

endmodule
