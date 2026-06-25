module C-STMT-LOOP
     imports C-CONFIGURATION
     imports K-EQUAL
     imports COMPAT-SYNTAX
     imports C-ABSTRACT-SYNTAX
     imports C-DYNAMIC-SYNTAX
     imports C-ELABORATOR-SYNTAX
     imports C-EXPR-LOGICAL-SYNTAX
     imports C-SYNTAX
     imports LIST
     imports C-ERROR-SYNTAX
     imports C-DECL-INITIALIZER-SYNTAX
     imports C-DECL-LOCAL
     imports C-TRANSLATION-ERROR-SYNTAX

     imports C-ELABORATOR

     rule For(Tag:Int, E1:KItem, E2:K, E3:K, B:K)
          => Block(Tag, list(ListItem(E1) ListItem(For(E2, E3, B)))) 

     // for(int i=0; i< N; i++){} E1:: int i=0; // for(int i=0; i< N; i++){B} For(E1; E2; E3){B}
     rule <k> OMPParallelFor(Tag:Int, list(OMP1:List), E1:KItem, E2:K, E3:K, B:K)
               => Block(Tag, list(ListItem(E1) ListItem(blockOMP(parseNumThreads(OMP1, TT), BeforeOmp(handleOmpClausesForBeforeOmp(OMP1, M)), AfterOmp(handleOmpClausesForAfterOmp(OMP1, M)), E2, E3, B))))
     	...</k>
     <omp-default-threads> TT:Int </omp-default-threads>
     <types> M:Map </types>

     // parallel{S} 
     rule <k> OMPParallel(Tag:Int, list(OMP1:List), S:K)
               => Block(Tag, list(ListItem(blockOmpParallel(parseNumThreads(OMP1, TT), BeforeOmp(handleOmpClausesForBeforeOmp(OMP1, M)), AfterOmp(handleOmpClausesForAfterOmp(OMP1, M)), S))))
     	...</k>
     <omp-default-threads> TT:Int </omp-default-threads>
     <types> M:Map </types>

          // for(int i=0; i< N; i++){} E1:: int i=0; // for(int i=0; i< N; i++){B} For(E1; E2; E3){B}
     rule <k> OMPFor(Tag:Int, list(OMP1:List), E1:KItem, E2:K, E3:K, B:K)
               => Block(Tag, list(ListItem(E1) ListItem(blockOmpFor(BeforeOmp(handleOmpClausesForBeforeOmp(OMP1, M)), AfterOmp(handleOmpClausesForAfterOmp(OMP1, M)), E2, E3, B))))
     	...</k>
     <types> M:Map </types>

     rule <k> OMPSection(Tag:Int, S:K)
               => Block(Tag, list(ListItem(blockOmpSection(S))))
     	...</k>

     // parallel sections{S} 
     rule <k> OMPParallelSections(Tag:Int, list(OMP1:List), list(S:List))
               => Block(Tag, list(ListItem(blockOmpParallelSections(parseNumThreads(OMP1, TT), BeforeOmp(handleOmpClausesForBeforeOmp(OMP1, M)), AfterOmp(handleOmpClausesForAfterOmp(OMP1, M)), list(S)))))
     	...</k>
     <omp-default-threads> TT:Int </omp-default-threads>
     <types> M:Map </types>


     // sections{S}
     rule <k> OMPSections(Tag:Int, list(OMP1:List), list(S:List))
               => Block(Tag, list(ListItem(blockOmpSections(BeforeOmp(handleOmpClausesForBeforeOmp(OMP1, M)), AfterOmp(handleOmpClausesForAfterOmp(OMP1, M)), list(S)))))
     	...</k>
          <types> M:Map </types>

     // section{S}
     rule <k> OMPSection(Tag:Int, S:K)
               => Block(Tag, list(ListItem(blockOmpSection(S))))
     	...</k>

     // single()
     rule <k> OMPSingle(Tag:Int, list(OMP1:List), S:K)
               => Block(Tag, list(ListItem(blockOmpSingle(BeforeOmp(handleOmpClausesForBeforeOmp(OMP1, M)), AfterOmp(handleOmpClausesForAfterOmp(OMP1, M)), S))))
     	...</k>
          <types> M:Map </types>

     // task
     rule <k> OMPTask(Tag:Int, list(OMP1:List), S:K)
               => Block(Tag, list(ListItem(blockOmpTask(BeforeOmp(handleOmpClausesForBeforeOmp(OMP1, M)), AfterOmp(handleOmpClausesForAfterOmp(OMP1, M)), S))))
     	...</k>
          <types> M:Map </types>

     // taskwait

     rule <k> OMPTaskWait(list(OMP1:List))
               => lineOmpTaskWait(AfterOmp(handleOmpClausesForAfterOmp(OMP1, M)))
     	...</k>
          <types> M:Map </types>


     rule ForClauseExpression(K:KItem) => Computation(K)

     context For((HOLE:KItem => reval(HOLE)), _, _) [result(RValue)]
     context blockOMP(_, _, _, (HOLE:KItem => reval(HOLE)), _, _) [result(RValue)]
     context blockOmpFor( _, _, (HOLE:KItem => reval(HOLE)), _, _) [result(RValue)]

     context For(_, (HOLE:KItem => reval(HOLE)), _) [result(RValue)]
     context blockOMP(_, _, _, _, (HOLE:KItem => reval(HOLE)), _) [result(RValue)]    
     context blockOmpFor( _, _, _, (HOLE:KItem => reval(HOLE)), _) [result(RValue)]    

     rule <k> For(Control:RValue, Post:RValue, S:K)
               => #for(simplifyTruth(Control), Post, S, L)
          ...</k>
          <curr-program-loc> L::CabsLoc </curr-program-loc>
          requires Control =/=K emptyValue
     
     rule For(emptyValue, Post:RValue, S:K)
          => #for(Post, S)
     // for-testing
     // rule <k> blockOMP(Th:Int, B:KItem, A:KItem, Control:K, Post:RValue, S:K)
     //       =>  jive
     //     ...</k>
     //	<curr-program-loc> L::CabsLoc </curr-program-loc>
     //	requires Control =/=K emptyValue 


     rule <k> blockOMP(Th:Int, B:KItem, A:KItem, Control:RValue, Post:RValue, S:K)
            =>  #blockOMP(Th, B, A, simplifyTruth(Control), Post, S, L)
          ...</k>
     	<curr-program-loc> L::CabsLoc </curr-program-loc>
     	requires Control =/=K emptyValue      
               	  
     rule blockOMP(Th:Int, B:KItem, A:KItem, emptyValue, Post:RValue, S:K)
          => #blockOMP(Th, B, A, Post, S)

     rule <k> blockOmpFor(B:KItem, A:KItem, Control:RValue, Post:RValue, S:K)
            =>  #blockOmpFor(B, A, simplifyTruth(Control), Post, S, L)
          ...</k>
     	<curr-program-loc> L::CabsLoc </curr-program-loc>
     	requires Control =/=K emptyValue      
               	  
     rule blockOmpFor(B:KItem, A:KItem, emptyValue, Post:RValue, S:K)
          => #blockOmpFor(B, A, Post, S)

     rule <k> blockOmpParallel(Th:Int, B:KItem, A:KItem, S:K)
            =>  #blockOmpParallel(Th, B, A, S, L)
          ...</k>
     	<curr-program-loc> L::CabsLoc </curr-program-loc>

     rule <k> blockOmpParallelSections(Th:Int, B:KItem, A:KItem, list(S:List))
            =>  #blockOmpParallelSections(Th, B, A, list(S), list(.List), L)
          ...</k>
     	<curr-program-loc> L::CabsLoc </curr-program-loc>

     rule <k> blockOmpSections(B:KItem, A:KItem, S:K)
            =>  #blockOmpSections(B, A, S, L)
          ...</k>
     	<curr-program-loc> L::CabsLoc </curr-program-loc>
             
     rule <k> blockOmpSection(S:K)
            =>  #blockOmpSection(S, L)
          ...</k>
     	<curr-program-loc> L::CabsLoc </curr-program-loc>

     rule <k> blockOmpSingle(B:KItem, A:KItem, S:K)
            =>  #blockOmpSingle(B, A, S, L)
          ...</k>
     	<curr-program-loc> L::CabsLoc </curr-program-loc>  

     rule <k> blockOmpTask(B:KItem, A:KItem, S:K)
            =>  #blockOmpTask(B, A, S, L)
          ...</k>
     	<curr-program-loc> L::CabsLoc </curr-program-loc>          
          
     syntax KItem ::= #for(K, RValue, K, CabsLoc) [klabel(#for4)]
                    | #for(RValue, K)             [klabel(#for2)]
                    

     syntax KItem ::= #blockOMP(Int, KItem, KItem, K, RValue, K, CabsLoc) [klabel(#blockOMP7)]
                    | #blockOMP(Int, KItem, KItem, RValue, K)             [klabel(#blockOMP5)]

     syntax KItem ::= #blockOmpFor(KItem, KItem, K, RValue, K, CabsLoc) [klabel(#blockOmpFor6)]
                    | #blockOmpFor(KItem, KItem, RValue, K)             [klabel(#blockOmpFor4)]

     syntax KItem ::= #blockOmpParallel(Int, KItem, KItem, K, CabsLoc) [klabel(#blockOmpParallel5)]     

     syntax KItem ::= #blockOmpParallelSections(Int, KItem, KItem, KItem, KItem, CabsLoc) [klabel(#blockOmpParallelSections6)]

     syntax KItem ::= #blockOmpSections(KItem, KItem, K, CabsLoc) [klabel(#blockOmpSections4)]   

     syntax KItem ::= #blockOmpSection(K, CabsLoc) [klabel(#blockOmpSection2)]   

     syntax KItem ::= #blockOmpSingle(KItem, KItem, K, CabsLoc) [klabel(#blockOmpSingle4)]   

     syntax KItem ::= #blockOmpTask(KItem, KItem, K, CabsLoc) [klabel(#blockOmpTask4)]   

     context #for((HOLE:KItem => reval(HOLE)), _, _, _) [result(RValue)]
     context #blockOMP(_, _, _, (HOLE:KItem => reval(HOLE)), _, _, _) [result(RValue)]
     context #blockOmpFor( _, _, (HOLE:KItem => reval(HOLE)), _, _, _) [result(RValue)]

     
     rule (.K => elaborate(S)) ~> #for(_:RValue, _, S:K, _)
     rule <k> elaborateDone(S:K)
               ~> #for(Control:RValue, Post:RValue, _, L::CabsLoc)
               => lintZero(Control) ~> lintEmpty(S)
          ...</k>
          <elab>... .K => For(compoundExp(L ~> Control), Post, S) </elab>

     rule (.K => elaborate(S)) ~> #for(_, S:K)
     rule <k> elaborateDone(S:K)
               ~> #for(Post:RValue, _)
               => lintEmpty(S)
          ...</k>
          <elab>... .K => For(emptyValue, Post, S) </elab>


     rule (.K => elaborate(S)) ~> #blockOMP(Th:Int, B:KItem, A:KItem, _:RValue, _, S:K, _)
     rule <k> elaborateDone(S:K)
               ~> #blockOMP(Th:Int, B:KItem, A:KItem, Control:RValue, Post:RValue, _, L::CabsLoc)
               => lintZero(Control) ~> lintEmpty(S)
          ...</k>
          <elab>... .K => blockOMP(Th, B, A, compoundExp(L ~> Control), Post, S) </elab>

     rule (.K => elaborate(S)) ~> #blockOMP(Th:Int, B:KItem, A:KItem, _, S:K)
     rule <k> elaborateDone(S:K)
               ~> #blockOMP(Th:Int, B:KItem, A:KItem, Post:RValue, _)
               => lintEmpty(S)
          ...</k>
          <elab>... .K => blockOMP(Th, B, A, emptyValue, Post, S) </elab>


     rule (.K => elaborate(S)) ~> #blockOmpFor( B:KItem, A:KItem, _:RValue, _, S:K, _)


     rule <k> elaborateDone(S:K)
               ~> #blockOmpFor( B:KItem, A:KItem, Control:RValue, Post:RValue, _, L::CabsLoc)
               => lintZero(Control) ~> lintEmpty(S)
          ...</k>
          <elab>... .K => blockOmpFor(B, A, compoundExp(L ~> Control), Post, S) </elab>

     rule (.K => elaborate(S)) ~> #blockOmpFor(B:KItem, A:KItem, _, S:K)
     rule <k> elaborateDone(S:K)
               ~> #blockOmpFor( B:KItem, A:KItem, Post:RValue, _)
               => lintEmpty(S)
          ...</k>
          <elab>... .K => blockOmpFor(B, A, emptyValue, Post, S) </elab>
          

     rule <k>
          (.K => elaborate(S)) ~> #blockOmpParallel(Th:Int, B:KItem, A:KItem, S:K, _)
          ...</k>
          <omp-block-history>(.List => ListItem(blockOmpParallel(Th, B, A, S))) O:List</omp-block-history>

     rule <k> elaborateDone(S:K)
               ~> #blockOmpParallel(Th:Int, B:KItem, A:KItem,  _, L::CabsLoc)
               => lintEmpty(S)
          ...</k>
          <elab>... .K => blockOmpParallel(Th, B, A, S) </elab>
          <omp-block-history>(ListItem(K1:KItem) => .List) O:List</omp-block-history>


     rule <k> #blockOmpParallelSections(Th:Int, B:KItem, A:KItem, list(ListItem(OMPSection(Tag:Int, S:K)) LL:List), list(RR:List), L::CabsLoc) 
                    => elaborate(S) ~> #blockOmpParallelSections(Th, B, A, list(LL), list(RR), L)
          ...</k>
          <omp-block-history>(.List => ListItem(blockOmpParallelSections(Th, B, A, list(appendList(RR, ListItem(OMPSection(Tag, S)) LL))))) O:List</omp-block-history>

     syntax KItem ::= testKItem(K)


     rule <k> elaborateDone(S:K)
               ~> #blockOmpParallelSections(Th:Int, B:KItem, A:KItem,  list(LL:List), list(RR:List), L::CabsLoc)
               => #blockOmpParallelSections(Th, B, A,  list(LL), list(RR ListItem(blockOmpSection(S))), L) ~> lintEmpty(S)
          ...</k>
          <omp-block-history>(ListItem(K1:KItem) => .List) O:List</omp-block-history>
          requires notBool isEmptyList(LL)

     rule <k> elaborateDone(S:K)
               ~> #blockOmpParallelSections(Th:Int, B:KItem, A:KItem,  list(LL:List), list(RR:List), L::CabsLoc)
               => lintEmpty(S)
          ...</k>
          <elab>... .K => blockOmpParallelSections(Th, B, A, list(RR ListItem(blockOmpSection(S)))) </elab>
          <omp-block-history>(ListItem(K1:KItem) => .List) O:List</omp-block-history>
          requires isEmptyList(LL)


     rule <k>
          (.K => elaborate(S)) ~> #blockOmpSections(B:KItem, A:KItem, S:K, _)
          ...</k>
          <omp-block-history>(.List => ListItem(blockOmpSections(B, A, S))) O:List</omp-block-history>

     rule <k> elaborateDone(S:K)
               ~> #blockOmpSections(B:KItem, A:KItem,  _, L::CabsLoc)
               => lintEmpty(S)
          ...</k>
          <elab>... .K => blockOmpSections(B, A, S) </elab>
          <omp-block-history>(ListItem(K1:KItem) => .List) O:List</omp-block-history>

     rule <k>
          (.K => elaborate(S)) ~> #blockOmpSection(S:K, _)
          ...</k>
          <omp-block-history>(.List => ListItem(blockOmpSection(S))) O:List</omp-block-history>

     rule <k> elaborateDone(S:K)
               ~> #blockOmpSection(_, L::CabsLoc)
               => lintEmpty(S)
          ...</k>
          <elab>... .K => blockOmpSection(S) </elab>
          <omp-block-history>(ListItem(K1:KItem) => .List) O:List</omp-block-history>

     rule <k>
          (.K => elaborate(S)) ~> #blockOmpSingle(B:KItem, A:KItem, S:K, L::CabsLoc)
          ...</k>
          <omp-block-history>(.List => ListItem(blockOmpSingle(B, A, S, L))) O:List</omp-block-history>

     rule <k> elaborateDone(S:K)
               ~> #blockOmpSingle(B:KItem, A:KItem,  _, L::CabsLoc)
               => lintEmpty(S)
          ...</k>
          <elab>... .K => blockOmpSingle(B, A, S, L) </elab>
          <omp-block-history>(ListItem(K1:KItem) => .List) O:List</omp-block-history>

     rule <k>
          (.K => elaborate(S)) ~> #blockOmpTask(B:KItem, A:KItem, S:K, L::CabsLoc)
          ...</k>
          <omp-block-history>(.List => ListItem(blockOmpTask(B, A, S))) O:List</omp-block-history>

     rule <k> elaborateDone(S:K)
               ~> #blockOmpTask(B:KItem, A:KItem,  _, L::CabsLoc)
               => lintEmpty(S)
          ...</k>
          <elab>... .K => blockOmpTask(B, A, S) </elab>
          <omp-block-history>(ListItem(K1:KItem) => .List) O:List</omp-block-history>

     rule <k> lineOmpTaskWait(B:KItem)
               => .K
          ...</k>
          <elab>... .K => lineOmpTaskWait(B) </elab>

     // TODO (cd-dpk) handle threadprivate
     // if a thread-private(static) variable is used inside #pragma, then the threadpriavte variable will behave like nonStatic variable
     rule <k> X:CId => le(X, type(Types[X])) ...</k>
          <omp-global-thread-private> Types::Map</omp-global-thread-private>
          <omp-block-history> L:List</omp-block-history>
          <env>... X |-> Base:DirectBase ...</env>
          <curr-tu> Tu::String </curr-tu>
          <tu-id> Tu </tu-id>
          <uses>... .Set => SetItem(X) ...</uses>
          <enums> Enums::Map </enums>
          requires notBool X in_keys(Enums)
          andBool X in_keys (Types)
          andBool notBool isEmptyList(L) 
          [structural]     

     syntax Bool ::= isEmptyList(List) [function]

     rule isEmptyList(ListItem(K1:KItem) L:List) => false
     rule isEmptyList(.List) => true

     context While((HOLE:KItem => reval(HOLE)), _) [result(RValue)]
     rule <k> While(B:RValue, S:K) => #while(simplifyTruth(B), S, L) ...</k>
          <curr-program-loc> L::CabsLoc </curr-program-loc>

     syntax KItem ::= #while(K, K, CabsLoc)
     context #while((HOLE:KItem => reval(HOLE)), _, _) [result(RValue)]
     rule (.K => elaborate(S)) ~> #while(_:RValue, S:K, _)
     rule <k> elaborateDone(S:K) ~> #while(B:RValue, _, L::CabsLoc)
               => lintZero(B) ~> lintEmpty(S)
          ...</k>
          <elab>... .K => While(compoundExp(L ~> B), S) </elab>

     context DoWhile((HOLE:KItem => reval(HOLE)), _, _) [result(RValue)]
     rule DoWhile(B:RValue, S:KItem, L:CabsLoc) => #doWhile(simplifyTruth(B), S, L)

     syntax KItem ::= #doWhile(K, K, CabsLoc)
     context #doWhile((HOLE:KItem => reval(HOLE)), _, _) [result(RValue)]
     rule (.K => elaborate(S)) ~> #doWhile(_:RValue, S:K, _)
     rule <k> elaborateDone(S:K) ~> #doWhile(B:RValue, _, L:CabsLoc)
               => lintZero(B) ~> lintEmpty(S)
          ...</k>
          <elab>... .K => DoWhile(compoundExp(L ~> B), S) </elab>

     rule <k> Continue() => .K ...</k>
          <elab>... .K => Continue() </elab>


     rule <k> OmpThreadPrivateList(list(ListItem(X:CId) L:List))
               => OmpThreadPrivateList(list(L))
          ...</k>
          <omp-global-thread-private> ThdPrvt:Map => ThdPrvt[X <- type(Types[X])] </omp-global-thread-private>
          <external-types>Types:Map</external-types>
          requires X in_keys(Types)

     rule <k> OmpThreadPrivateList(list(.List))
               => .K
          ...</k>        



    /******************************************************
     *    Helping Function
     ******************************************************/

     syntax List ::= appendList(List, List) [function]

     rule appendList(L1:List, ListItem(K1:KItem)  L2:List) => appendList(L1 ListItem(K1), L2)
     rule appendList(L1:List, .List) => L1
     
     syntax Bool ::= isOmpFor(KItem) [function]
     rule isOmpFor(OMPFor(_, _, _, _, _, _)) => true
     rule isOmpFor(_) => false [owise]


     syntax List ::= funBeforeOmpFor(List, List) [function]
     rule funBeforeOmpFor(ListItem(CodeLoc(K1:KItem, Line:CabsLoc)) L:List, A:List) => A
     requires isOmpFor(K1)
     rule funBeforeOmpFor(ListItem(CodeLoc(K1:KItem, Line:CabsLoc)) L:List, A:List) => funBeforeOmpFor(L, A ListItem(CodeLoc(K1, Line)))
     requires notBool isOmpFor(K1)
     rule funBeforeOmpFor(.List, A:List) => A


     syntax List ::= funAfterOmpFor(List) [function]
     rule funAfterOmpFor(ListItem(CodeLoc(K1:KItem, Line:CabsLoc)) L:List) => L
     requires isOmpFor(K1)
     rule funAfterOmpFor(ListItem(CodeLoc(K1:KItem, Line:CabsLoc)) L:List) => funAfterOmpFor(L)
     requires notBool isOmpFor(K1)
     rule funAfterOmpFor(.List) => .List


     syntax List ::= funOmpFor(List) [function]
     rule funOmpFor(ListItem(CodeLoc(K1:KItem, Line:CabsLoc)) L:List) => ListItem(CodeLoc(K1:KItem, Line:CabsLoc))
     requires isOmpFor(K1)
     rule funOmpFor(ListItem(CodeLoc(K1:KItem, Line:CabsLoc)) L:List) => funOmpFor(L)
     requires notBool isOmpFor(K1)
     rule funOmpFor(.List) => .List




      /*************************
     * Handling OMP Clauses - BEFORE
     **************************/
     syntax K ::= handleOmpClausesForBeforeOmp(List, Map) [function]

     rule handleOmpClausesForBeforeOmp(.List, M:Map) => .K 

     rule handleOmpClausesForBeforeOmp(ListItem(OmpPrivateList(list(L1:List))) L:List, M:Map) => handlePrivateClasueBefore(L1, M) ~> handleOmpClausesForBeforeOmp(L,M)

     rule handleOmpClausesForBeforeOmp(ListItem(OmpSharedList(list(L1:List))) L:List, M:Map) => handleSharedClasueBefore(L1, M) ~> handleOmpClausesForBeforeOmp(L,M)

     rule handleOmpClausesForBeforeOmp(ListItem(OmpFirstPrivateList(list(L1:List))) L:List, M:Map) => handleFirstPrivateClauseBefore(L1, M) ~> handleOmpClausesForBeforeOmp(L,M)

     rule handleOmpClausesForBeforeOmp(ListItem(OmpLastPrivateList(S:String, list(L1:List))) L:List, M:Map) => handleLastPrivateClauseBefore(L1, M) ~> handleOmpClausesForBeforeOmp(L,M)

     rule handleOmpClausesForBeforeOmp(ListItem(OmpReduction(S1:String, S2:String, list(L1:List))) L:List, M:Map) => handleReductionClausePlusBefore(L1, M) ~> handleOmpClausesForBeforeOmp(L,M)
     requires S2 ==String "+"

     rule handleOmpClausesForBeforeOmp(ListItem(OmpReduction(S1:String, S2:String, list(L1:List))) L:List, M:Map) => handleReductionClauseProdBefore( L1, M) ~> handleOmpClausesForBeforeOmp(L,M)
     requires S2 ==String "*"
     
     rule handleOmpClausesForBeforeOmp(ListItem(OmpNumThreads(N:Int)) L:List, M:Map) => handleOmpClausesForBeforeOmp(L,M)

     /*****************************
     * Helper Function - Before
     *****************************/

     syntax K ::= handlePrivateClasueBefore(List, Map) [function]
     syntax K ::= handleSharedClasueBefore(List, Map) [function]
     syntax K ::= handleFirstPrivateClauseBefore(List, Map) [function]
     syntax K ::= handleLastPrivateClauseBefore(List, Map) [function]
     syntax K ::= handleReductionClausePlusBefore(List, Map) [function]
     syntax K ::= handleReductionClauseProdBefore(List, Map) [function]
     

     rule handlePrivateClasueBefore(.List, M:Map) => .K
     rule handleSharedClasueBefore(.List, M:Map) => .K
     rule handleFirstPrivateClauseBefore(.List, M:Map) => .K
     rule handleLastPrivateClauseBefore(.List, M:Map) => .K

     rule handleReductionClausePlusBefore(.List, M:Map) => .K
     rule handleReductionClauseProdBefore(.List, M:Map) => .K

     rule handlePrivateClasueBefore(ListItem(X:CId) L:List, M:Map) =>  declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), .K)) ~> handlePrivateClasueBefore(L, M)
     requires X in_keys(M)

     rule handleSharedClasueBefore(ListItem(X:CId) L:List, M:Map) =>  OmpSharedVar(X) ~> handleSharedClasueBefore(L, M)
     requires X in_keys(M)

     rule handleFirstPrivateClauseBefore(ListItem(X:CId) L:List, M:Map) =>  declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), Initializer(X := OmpParentVar(X)))) ~> handleFirstPrivateClauseBefore(L, M)
     requires X in_keys(M)

     rule handleLastPrivateClauseBefore(ListItem(X:CId) L:List, M:Map) =>  declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), .K)) ~> handleFirstPrivateClauseBefore(L, M)
     requires X in_keys(M)


     rule handleReductionClausePlusBefore(ListItem(X:CId) L:List, M:Map) =>  declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), Initializer(X := tv(0, utype(type(M[X])))))) ~> handleReductionClausePlusBefore(L, M)
     requires X in_keys(M)
     
     rule handleReductionClauseProdBefore(ListItem(X:CId) L:List, M:Map) =>  declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), Initializer(X := tv(1, utype(type(M[X])))))) ~> handleReductionClauseProdBefore(L, M)
     requires X in_keys(M)


     /*************************
     * Handling OMP Clauses - After
     **************************/
     syntax K ::= handleOmpClausesForAfterOmp(List, Map) [function]
     // Terminate if empty List
     rule handleOmpClausesForAfterOmp(.List, M:Map) => .K 
     // ignore if private()
     rule handleOmpClausesForAfterOmp(ListItem(OmpPrivateList(list(L1:List))) L:List, M:Map) => handleOmpClausesForAfterOmp(L,M)
     // ignore if shared
     rule handleOmpClausesForAfterOmp(ListItem(OmpSharedList(list(L1:List))) L:List, M:Map) => handleOmpClausesForAfterOmp(L,M)
     // ignore if firstprivate()
     rule handleOmpClausesForAfterOmp(ListItem(OmpFirstPrivateList(list(L1:List))) L:List, M:Map) =>  handleOmpClausesForAfterOmp(L,M)
     // ignore if lastprivate()
     rule handleOmpClausesForAfterOmp(ListItem(OmpLastPrivateList(S:String, list(L1:List))) L:List, M:Map) => handleLastPrivateClauseAfter(L1, M) ~> handleOmpClausesForAfterOmp(L,M)
     // add computation if reduction
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
     syntax K ::= handleLastPrivateClauseAfter(List, Map) [function]
     syntax K ::= handleReductionClausePlusAfter(List, Map) [function]
     syntax K ::= handleReductionClauseProdAfter(List, Map) [function]

     rule handleReductionClausePlusAfter(.List, M:Map) => .K
     rule handleReductionClauseProdAfter(.List, M:Map) => .K
     rule handleLastPrivateClauseAfter(.List, M:Map) => .K
 
     // Computation(te( OmpParentVar(X) := OmpParentVar(X) + X, rvalType(type(M[X]))))
     // update after each last-private
     rule handleLastPrivateClauseAfter(ListItem(X:CId) L:List, M:Map) =>  OmpLastPrivateItem(X) ~> handleLastPrivateClauseAfter(L, M)
     requires X in_keys(M)
     // add plus computation
     rule handleReductionClausePlusAfter(ListItem(X:CId) L:List, M:Map) =>  Computation(te( OmpParentVar(X) := OmpParentVar(X) + X, rvalType(type(M[X])))) ~> handleReductionClausePlusAfter(L, M)
     requires X in_keys(M)
     // add product computation
     rule handleReductionClauseProdAfter(ListItem(X:CId) L:List, M:Map) =>  Computation(te( OmpParentVar(X) := OmpParentVar(X) * X, rvalType(type(M[X])))) ~> handleReductionClauseProdAfter(L, M)
     requires X in_keys(M)


     // IF A DOES NOT EXIST
     /**
     rule handlePrivateClasueBefore(ListItem(X:CId) L:List, M:Map) =>  IMPL("JIVE1", "PRIVATE:: Variable is not declared.") ~> handlePrivateClasueBefore(L, M)
     requires notBool X in_keys(M)
     
     rule handleFirstPrivateClauseBefore(ListItem(X:CId) L:List, M:Map) =>  IMPL("JIVE1", "FIRSTPRIVATE:: Variable is not declared.") ~> handleFirstPrivateClauseBefore(L, M)
     requires notBool X in_keys(M) 

     rule handleLastPrivateClause(ListItem(X:CId) L:List, M:Map) =>  IMPL("JIVE1", "FIRSTPRIVATE:: Variable is not declared.") ~> handleLastPrivateClause(L, M)
     requires notBool X in_keys(M)  
     
     rule handleReductionClausePlus(ListItem(X:CId) L:List, M:Map) =>  IMPL("JIVE1", "FIRSTPRIVATE:: Variable is not declared.") ~> handleLastPrivateClause(L, M)
     requires notBool X in_keys(M)          

     rule handleReductionClauseProd(ListItem(X:CId) L:List, M:Map) =>  IMPL("JIVE1", "FIRSTPRIVATE:: Variable is not declared.") ~> handleLastPrivateClause(L, M)
     requires notBool X in_keys(M)          
     */

     /****************************
     *    Parsing num_threads()  *
     *****************************/
     syntax Int ::= parseNumThreads(List, Int) [function]

     rule parseNumThreads(ListItem(K1:KItem) L:List, T:Int) => parseNumThreads(L, T)
     requires notBool isOmpNumThreads(K1)
     
     rule parseNumThreads(ListItem(K1:KItem) L:List, T:Int) => getNumThreads(K1)
     requires isOmpNumThreads(K1)
     
     rule parseNumThreads(.List, T:Int) => T
     
     syntax Bool ::= isOmpNumThreads(KItem) [function]
     rule isOmpNumThreads(OmpNumThreads(N:Int)) => true
     rule isOmpNumThreads(_) => false [owise]

     syntax Int ::= getNumThreads(KItem) [function]
     rule getNumThreads(OmpNumThreads(N:Int)) => N -Int 1
     requires N >=Int 1

     rule getNumThreads(OmpNumThreads(N:Int)) => 0
     requires N <=Int 0

endmodule
