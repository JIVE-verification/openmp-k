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

     rule For(Tag:Int, E1:KItem, E2:K, E3:K, B:K)
          => Block(Tag, list(ListItem(E1) ListItem(For(E2, E3, B)))) 

     // for(int i=0; i< N; i++){} E1:: int i=0; // for(int i=0; i< N; i++){B} For(E1; E2; E3){B}
     rule <k> OMPFor(Tag:Int, list(OMP1:List), E1:KItem, E2:K, E3:K, B:K)
               => Block(Tag, list(ListItem(E1) ListItem(blockOMP(parseNumThreads(OMP1, TT), BeforeOmp(handleOmpClausesForBeforeOmp(OMP1, M)), AfterOmp(handleOmpClausesForAfterOmp(OMP1, M)), E2, E3, B))))
     	...</k>
     <omp-default-threads> TT:Int </omp-default-threads>
     <types> M:Map </types>

     /*************************
     * Handling OMP Clauses - BEFORE
     **************************/
     syntax K ::= handleOmpClausesForBeforeOmp(List, Map) [function]

     rule handleOmpClausesForBeforeOmp(.List, M:Map) => .K 

     rule handleOmpClausesForBeforeOmp(ListItem(OmpPrivateList(list(L1:List))) L:List, M:Map) => handlePrivateClasueBefore(L1, M) ~> handleOmpClausesForBeforeOmp(L,M)

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
     syntax K ::= handleFirstPrivateClauseBefore(List, Map) [function]
     syntax K ::= handleLastPrivateClauseBefore(List, Map) [function]
     syntax K ::= handleReductionClausePlusBefore(List, Map) [function]
     syntax K ::= handleReductionClauseProdBefore(List, Map) [function]

     rule handlePrivateClasueBefore(.List, M:Map) => .K
     rule handleFirstPrivateClauseBefore(.List, M:Map) => .K
     rule handleLastPrivateClauseBefore(.List, M:Map) => .K

     rule handleReductionClausePlusBefore(.List, M:Map) => .K
     rule handleReductionClauseProdBefore(.List, M:Map) => .K

     rule handlePrivateClasueBefore(ListItem(X:CId) L:List, M:Map) =>  declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), .K)) ~> handlePrivateClasueBefore(L, M)
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
 
     // update after each private
     rule handleLastPrivateClauseAfter(ListItem(X:CId) L:List, M:Map) =>  Computation(te( OmpParentVar(X) := OmpParentVar(X) + X, rvalType(type(M[X])))) ~> handleLastPrivateClauseAfter(L, M)
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


     rule ForClauseExpression(K:KItem) => Computation(K)

     context For((HOLE:KItem => reval(HOLE)), _, _) [result(RValue)]
     context blockOMP(_, _, _, (HOLE:KItem => reval(HOLE)), _, _) [result(RValue)]

     context For(_, (HOLE:KItem => reval(HOLE)), _) [result(RValue)]
     context blockOMP(_, _, _, _, (HOLE:KItem => reval(HOLE)), _) [result(RValue)]    

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

             
     syntax KItem ::= #for(K, RValue, K, CabsLoc) [klabel(#for4)]
                    | #for(RValue, K)             [klabel(#for2)]
                    

     syntax KItem ::= #blockOMP(Int, KItem, KItem, K, RValue, K, CabsLoc) [klabel(#blockOMP7)]
                    | #blockOMP(Int, KItem, KItem, RValue, K)             [klabel(##blockOMP5)]
                     
                    
     context #for((HOLE:KItem => reval(HOLE)), _, _, _) [result(RValue)]
     context #blockOMP(_, _, _, (HOLE:KItem => reval(HOLE)), _, _, _) [result(RValue)]

     
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

//      syntax String ::= Int2String ( Int )               [function, total, hook(STRING.int2string)]
        syntax CId ::= String2Id (String) [function, total, hook(STRING.string2token)]
       
     // i < N => omp_temp_var
     // OPENMP Fresh Variables
//     		=> decl(int, "temp_" +String Int2String(V))
//     		=> decl("int", "temp_")
//			=> id("temp_")
     syntax CId ::= "ompFreshVar"
     rule <k> ompFreshVar => Assign(String2Id("temp" +String Int2String(V)), TT) ...</k>
     <omp-temp-var> V:Int => V +Int 1 </omp-temp-var>
     <omp-default-threads> TT:Int </omp-default-threads>
     // decl(int, string)          
          
     //rule <k> OMPFor(Tag:Int, E1:KItem, E2:K, E3:K, B:K)
     //     => Block(Tag, list(ListItem(ompFreshVar) ListItem(TT) ListItem(E1) ListItem(For(E2, E3, B))))
     //		... </k>
// original 
//     rule <k> OMPFor(Tag:Int, E1:KItem, E2:K, E3:K, B:K)
//          => Block(Tag, list(ListItem(handleE1(E1)) ListItem(PFor(E2, E3, B))))
//      	 ...</k>
          
//     rule <k> OMPFor(Tag:Int, E1:KItem, E2:K, E3:K, B:K)
//          => handleE1(E1) ~> OMPForr(Tag, E1, E2, E3, B)
//      	 ...</k>      	 
//[function]
//   syntax KItem ::= handleE2(KItem, KItem) [function]

//     rule <k>
//     		OMPFor(Tag:Int, DeclarationDefinition(InitNameGroup(T:Type, list(ListItem(InitName(N:KItem, Exp:KItem))))), E2:K, E3:K, B:K) 
//     		=> Block(Tag, list(ListItem(DeclarationDefinition(InitNameGroup(T, list(ListItem(InitName(N, TT)))))) ListItem(PFor(E2, E3, B)))) 
//     	   ...</k>
//     <omp-default-threads> TT:Int </omp-default-threads>
     
//     rule <k>
//     		handleE1(CodeLoc(DeclarationDefinition(InitNameGroup(T:Type, list(ListItem(InitName(N:KItem, Exp:KItem))))), L::CabsLoc))
//     		=>  CodeLoc(DeclarationDefinition(InitNameGroup(T, list(ListItem(InitName(N, TT))))), L)
//     	   ...</k>
//     <omp-default-threads> TT:Int </omp-default-threads>
     
//     rule <k>
//     		handleE1(CodeLoc(K:K, L:CabsLoc))
//     		=>  CodeLoc(K, L)
//     	   ...</k>
//     <omp-default-threads> TT:Int </omp-default-threads>

//     rule <k>
//     		handleE1(CodeLoc(DeclarationDefinition(InitNameGroup(T:Type, list(ListItem(InitName(N:KItem, Exp:KItem))))), L:CabsLoc))
//     		=>  CodeLoc(TT, L)
//     	   ...</k>
//        <omp-default-threads> TT:Int </omp-default-threads>
// IT WORKED
//	rule <k>
//     		handleE1(CodeLoc(DeclarationDefinition(InitNameGroup(T, list(ListItem(InitName(N, Exp))))), L:CabsLoc))
//     		=>  CodeLoc(DeclarationDefinition(InitNameGroup(T, list(ListItem(InitName(N, TT))))), L)
//     	   ...</k>
//        <omp-default-threads> TT:Int </omp-default-threads>


endmodule
