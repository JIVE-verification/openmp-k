module C-STMT-LOOP
     imports C-CONFIGURATION
     imports K-EQUAL
     imports COMPAT-SYNTAX
     imports C-ABSTRACT-SYNTAX
     imports C-DYNAMIC-SYNTAX
     imports C-ELABORATOR-SYNTAX
     imports C-EXPR-LOGICAL-SYNTAX
     imports C-SYNTAX
     imports C-TRANSLATION-ERROR-SYNTAX

     rule For(Tag:Int, E1:KItem, E2:K, E3:K, B:K)
          => Block(Tag, list(ListItem(E1) ListItem(For(E2, E3, B)))) 
          
     // for(int i=0; i< N; i++){} E1:: int i=0;
     
     rule <k> OMPFor(Tag:Int, E1:KItem, E2:K, E3:K, B:K)
     		=> blockOMP(TT, ompTempVar(V), OMPFor(Tag, E1, E2, E3, B))
     	...</k>
     <omp-default-threads> TT:Int </omp-default-threads> 
     <omp-temp-var> V:Int => V +Int 1 </omp-temp-var>
     
     rule <k> blockOMP(TT:Int, Temp:CId,  OMPFor(Tag:Int, E1:KItem, E2:K, E3:K, B:K))
          => handleE1(E1) ~> blockOMP(TT, Temp,  OMPForr(Tag, E1, E2, E3, B))
      	 ...</k>      	 
     rule <k>
     		handleE1(E1:KItem) ~> blockOMP(Th:Int, Temp:CId, OMPForr(Tag:Int, E1:KItem, E2:K, E3:K, B:K))
     		=>  blockOMP(Th, Temp, OMPForr(Tag, E1, E2, E3, B) )
     	 ...</k>
     <omp-default-threads> TT:Int </omp-default-threads>      	      	 
     
     rule <k> blockOMP(Th:Int, Temp:CId, OMPForr(Tag:Int, E1:KItem, E2:K, E3:K, B:K))
          => handleE2(E2) ~> blockOMP(Th:Int, Temp:CId, OMPForrr(Tag, E1, E2, E3, B))
      	 ...</k>
      	 
     rule <k>
     	  handleE2(E2:K) ~> blockOMP(Th:Int, Temp:CId, OMPForrr(Tag:Int, E1:KItem, E2:K, E3:K, B:K))
     		=>  blockOMP(Th, Temp, OMPForrr(Tag, E1, E2, E3, B) )
     	   ...</k>
     <omp-default-threads> TT:Int </omp-default-threads>

    // rule <k> blockOMP(Th:Int, Temp:CId, OMPForrr(Tag:Int, E1:KItem, E2:K, E3:K, B:K))
    //      => Block(Tag, list(ListItem(E1) ListItem(Th) ListItem(Temp) ListItem(PFor(E2, E3, B))))
    // ...</k>
    
     // for(int i=0; i< N; i++){B} For(E1; E2; E3){B}
    rule <k> blockOMP(Th:Int, Temp:CId, OMPForrr(Tag:Int, E1:KItem, E2:K, E3:K, B:K))
        => Block(Tag, list(ListItem(E1) ListItem(blockOMP(Th, Temp, E2, E3, B))))
     ...</k>
    
//    context blockOMP((HOLE:KItem => reval(HOLE)),_,_,_) [result(RValue)]
//    context blockOMP(_,(HOLE:KItem => reval(HOLE)),_,_) [result(RValue)]
//    context blockOMP(_,_,(HOLE:KItem => reval(HOLE)),_) [result(RValue)]
//    rule <k> blockOMP(Th:Int, Temp:CId, For(E2:K, E3:K, B:K))
//    		=> Th ~> Temp ~> E1 ~> For(E2, E3, B)
//    ...</k>
      	 
	 syntax KItem ::= handleE1(KItem) 
	 syntax KItem ::= handleE2(K) 
                    
     rule ForClauseExpression(K:KItem) => Computation(K)
     //rule blockOMPClauseExpression(K:KItem) => Computation(K)

     context For((HOLE:KItem => reval(HOLE)), _, _) [result(RValue)]
     context blockOMP(_:Int,_:CId,(HOLE:KItem => reval(HOLE)), _, _) [result(RValue)]


     context For(_, (HOLE:KItem => reval(HOLE)), _) [result(RValue)]
     context blockOMP(_:Int,_:CId, _, (HOLE:KItem => reval(HOLE)), _) [result(RValue)]    
     
     rule <k> For(Control:RValue, Post:RValue, S:K)
               => #for(simplifyTruth(Control), Post, S, L)
          ...</k>
          <curr-program-loc> L::CabsLoc </curr-program-loc>
          requires Control =/=K emptyValue
     rule For(emptyValue, Post:RValue, S:K)
          => #for(Post, S)

     rule <k> blockOMP(Th:Int, Temp:CId, Control:RValue, Post:RValue, S:K)
            =>  #blockOMP(Th, Temp, simplifyTruth(Control), Post, S, L)
          ...</k>
     	<curr-program-loc> L::CabsLoc </curr-program-loc>
     	requires Control =/=K emptyValue      
               	  
     rule blockOMP(Th:Int, Temp:CId, emptyValue, Post:RValue, S:K)
          => #blockOMP(Th, Temp, Post, S)

             
     syntax KItem ::= #for(K, RValue, K, CabsLoc) [klabel(#for4)]
                    | #for(RValue, K)             [klabel(#for2)]
                    
     syntax KItem ::= #pfor(K, RValue, K, CabsLoc) [klabel(#pfor4)]
                    | #pfor(RValue, K)             [klabel(#pfor2)]

     syntax KItem ::= #blockOMP(Int, CId, K, RValue, K, CabsLoc) [klabel(#blockOMP6)]
                    | #blockOMP(Int, CId, RValue, K)             [klabel(##blockOMP4)]
                    
     context #for((HOLE:KItem => reval(HOLE)), _, _, _) [result(RValue)]
     context #blockOMP(_,_,(HOLE:KItem => reval(HOLE)), _, _, _) [result(RValue)]

     
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


     rule (.K => elaborate(S)) ~> #blockOMP(Th:Int, Temp:CId, _:RValue, _, S:K, _)
     rule <k> elaborateDone(S:K)
               ~> #blockOMP(Th:Int, Temp:CId, Control:RValue, Post:RValue, _, L::CabsLoc)
               => lintZero(Control) ~> lintEmpty(S)
          ...</k>
          <elab>... .K => blockOMP(Th, Temp, compoundExp(L ~> Control), Post, S) </elab>

     rule (.K => elaborate(S)) ~> #blockOMP(Th:Int, Temp:CId, _, S:K)
     rule <k> elaborateDone(S:K)
               ~> #blockOMP(Th:Int, Temp:CId, Post:RValue, _)
               => lintEmpty(S)
          ...</k>
          <elab>... .K => blockOMP(Th, Temp, emptyValue, Post, S) </elab>

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
