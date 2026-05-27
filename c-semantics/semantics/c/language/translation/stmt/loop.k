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

     imports C-TRANSLATION-ERROR-SYNTAX

     rule For(Tag:Int, E1:KItem, E2:K, E3:K, B:K)
          => Block(Tag, list(ListItem(E1) ListItem(For(E2, E3, B)))) 
          
     // for(int i=0; i< N; i++){} E1:: int i=0;
     rule <k> OMPFor(Tag:Int, list(OMP1:List), E1:KItem, E2:K, E3:K, B:K)
               => ompClauseExpr(handleOmpClauses(OMP1, M))
     	...</k>
     <omp-default-threads> TT:Int </omp-default-threads>
     <omp-temp-var> V:Int => V +Int 1 </omp-temp-var>
     <types> M:Map </types>

     // semantics/common/compat.k:40:     syntax K ::= listToK(List) [function]
     // semantics/common/compat.k:249:     rule listToK(ListItem(K:KItem) L:List) => K ~> listToK(L)
     // semantics/common/compat.k:250:     rule listToK(.List) => .K

     syntax K ::= handleOmpClauses(List, Map) [function]

     rule handleOmpClauses(.List, M:Map) => .K 
     rule handleOmpClauses(ListItem(OmpPrivateList(list(L1:List))) L:List, M:Map) => handlePrivateClasue(L1, M) ~> handleOmpClauses(L,M)

     syntax K ::= handlePrivateClasue(List, Map) [function]

     rule handlePrivateClasue(.List, M:Map) => .K

     rule handlePrivateClasue(ListItem(A:CId) L:List, M:Map) =>  declareInternalVariable(A, M[A], NoInit()) ~> handlePrivateClasue(L, M)
     requires A in_keys(M)

     rule handlePrivateClasue(ListItem(A:CId) L:List, M:Map) =>  IMPL("JIVE1",
               "Variable is not declared.") ~> handlePrivateClasue(L, M)
     requires notBool A in_keys(M)

     // testing 
     rule <k> ompClauseExpr(K:K)
               => K
          ...</k>

     // for(int i=0; i< N; i++){B} For(E1; E2; E3){B}
    rule <k> blockOMP(Th:Int, Temp:CId, K:K, OMPForr(Tag:Int, E1:KItem, E2:K, E3:K, B:K))
        => Block(Tag, list(ListItem(E1) ListItem(blockOMP(Th, Temp, E2, E3, B))))
     ...</k>   
                    
     rule ForClauseExpression(K:KItem) => Computation(K)

     context For((HOLE:KItem => reval(HOLE)), _, _) [result(RValue)]
     context blockOMP(_:Int, _:CId, _:KItem, (HOLE:KItem => reval(HOLE)), _, _) [result(RValue)]

     context For(_, (HOLE:KItem => reval(HOLE)), _) [result(RValue)]
     context blockOMP(_:Int, _:CId, _:KItem, _, (HOLE:KItem => reval(HOLE)), _) [result(RValue)]    

     rule <k> For(Control:RValue, Post:RValue, S:K)
               => #for(simplifyTruth(Control), Post, S, L)
          ...</k>
          <curr-program-loc> L::CabsLoc </curr-program-loc>
          requires Control =/=K emptyValue
     
     rule For(emptyValue, Post:RValue, S:K)
          => #for(Post, S)

     rule <k> blockOMP(Th:Int, Temp:CId, C:KItem, Control:K, Post:RValue, S:K)
            =>  jive
          ...</k>
     	<curr-program-loc> L::CabsLoc </curr-program-loc>
     	requires Control =/=K emptyValue 


     rule <k> blockOMP(Th:Int, Temp:CId, C:KItem, Control:RValue, Post:RValue, S:K)
            =>  #blockOMP(Th, Temp, C, simplifyTruth(Control), Post, S, L)
          ...</k>
     	<curr-program-loc> L::CabsLoc </curr-program-loc>
     	requires Control =/=K emptyValue      
               	  
     rule blockOMP(Th:Int, Temp:CId, C:KItem, emptyValue, Post:RValue, S:K)
          => #blockOMP(Th, Temp, C, Post, S)

             
     syntax KItem ::= #for(K, RValue, K, CabsLoc) [klabel(#for4)]
                    | #for(RValue, K)             [klabel(#for2)]
                    

     syntax KItem ::= #blockOMP(Int, CId, KItem, K, RValue, K, CabsLoc) [klabel(#blockOMP7)]
                    | #blockOMP(Int, CId, KItem, RValue, K)             [klabel(##blockOMP5)]
                     
                    
     context #for((HOLE:KItem => reval(HOLE)), _, _, _) [result(RValue)]
     context #blockOMP(_, _,  _, (HOLE:KItem => reval(HOLE)), _, _, _) [result(RValue)]

     
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


     rule (.K => elaborate(S)) ~> #blockOMP(Th:Int, Temp:CId, ClauseExpr:KItem, _:RValue, _, S:K, _)
     rule <k> elaborateDone(S:K)
               ~> #blockOMP(Th:Int, Temp:CId, ClauseExpr:KItem, Control:RValue, Post:RValue, _, L::CabsLoc)
               => lintZero(Control) ~> lintEmpty(S)
          ...</k>
          <elab>... .K => blockOMP(Th, Temp, ClauseExpr, compoundExp(L ~> Control), Post, S) </elab>

     rule (.K => elaborate(S)) ~> #blockOMP(Th:Int, Temp:CId, ClauseExpr:KItem, _, S:K)
     rule <k> elaborateDone(S:K)
               ~> #blockOMP(Th:Int, Temp:CId, ClauseExpr:KItem, Post:RValue, _)
               => lintEmpty(S)
          ...</k>
          <elab>... .K => blockOMP(Th, Temp, ClauseExpr, emptyValue, Post, S) </elab>

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
