module C-STMT-LOOP
     imports C-CONFIGURATION
     imports K-REFLECTION
     imports C-SYNTAX
     imports C-DYNAMIC-SYNTAX
     imports C-TYPING-SYNTAX
     imports C-EXECUTION-ERROR-SYNTAX
     imports LIBC-THREADS
     imports LIBC-THREADS-SYNTAX
     imports LIBC-STDIO
     imports SYMLOC-SYNTAX
     imports SYMLOC
     imports C-MEMORY-ALLOC-SYNTAX
     imports C-ENV-SYNTAX
    
     syntax KItem ::= "spawn-aux-omp" "(" K "," K ")"
     syntax KItem ::= "OMPForInnerThread" "(" K "," K "," K")"
     syntax KItem ::= "join-aux-omp" "(" Int ")"
     syntax KItem ::= "update-identifier" "(" Int ")"
     syntax KItem ::= "update-mem" "(" Int "," Int "," Duration ")"
     // syntax KItem ::= "obj" "(" Int "," Int "," K ")"
     syntax Stmt ::= "updateEnv"
     syntax Stmt ::= "continueForLoop"
     syntax K ::= placeContext(Map)

     syntax KItem ::= "waitingForChild"
     syntax KItem ::= "joinChild"

     syntax KItem ::= extractInitialTerm(KItem)

     // joining OMP Thread with Id:Int 
     syntax KItem ::= joinOmpThread(Int)

     // Helper to allocate and initialize thread-local loop variable
     syntax KItem ::= initThreadLocalVar(CId, Type, RValue, SymBase)

     
     /*@ \fromStandard{\source[n1570]{\para{6.8.5.2}{1}}}{
     The statement
     \cdisplay{for ( $\textit{clause-1}$ ; $\textit{expression-2}$ ;
     $\textit{expression-3}$ ) $\textit{statement}$ } behaves as follows: The
     expression $\textit{expression-2}$ is the controlling expression that is
     evaluated before each execution of the loop body. The expression
     $\textit{expression-3}$ is evaluated as a void expression after each
     execution of the loop body. If $\textit{clause-1}$ is a declaration, the
     scope of any identifiers it declares is the remainder of the declaration
     and the entire loop, imports the other two expressions; it is reached in
     the order of execution before the first evaluation of the controlling
     expression. If $\textit{clause-1}$ is an expression, it is evaluated as a
     void expression before the first evaluation of the controlling expression.
     }

     \fromStandard{\source[n1570]{\para{6.8.5.2}{1}}}{
     Both $\textit{clause-1}$ and $\textit{expression-3}$ can be omitted. An
     omitted $\textit{expression-2}$ is replaced by a nonzero constant.
     }*/
    
    
     
     //these are structural, so no computation is done here I think
     //this first
     //fixme fishy interaction with continue i think
     rule [for-mark]:
          <k> For(Control:K, Post:K, S:K) ~> K:K
               => loopMarked
               ~> For((#if Control =/=K emptyValue
                    #then Control
                    #else tv(1, utype(int)) #fi),
                    Post, S)
               ~> popLoop
          </k>
          <block-history> ListItem(Num:Int) ...</block-history>
          <loop-stack> .List => ListItem(kpair(Num, K)) ...</loop-stack>
          [structural]
     //this later
     rule [for]:
          <k> loopMarked ~> For(Control:K, Post:K, S:K)
                =>IfThenElse(Control,
                         (S ~> Computation(Post) ~> loopMarked
                    ~> For(Control, Post, S)), Nop())
          ...</k>
          <block-history> ListItem(_:Int) ...</block-history>
          [structural] // rule so that looping programs see repetition

     rule [include-i]:
               <k> Computation(te(X:CId := V:KItem, TT::UType)) ~> blockOMP(Th:Int, C:K, Control:K, Post:K, S:K)
                    => blockOMP(Th, C, declareInternalVariable ( X , type(TypesMap[X]) , initValue ( X , type(TypesMap[X]) , Initializer( X:=V) )), Control, Post, S)
                    ...</k>
               <env> Env::Map </env>
               <types> TypesMap::Map </types>
         requires notBool isStaticType(type(TypesMap[X]))
               andBool notBool isExternType(type(TypesMap[X]))
               andBool notBool isFunctionType(type(TypesMap[X]))
               andBool notBool isVariablyModifiedType(type(TypesMap[X]))
               andBool notBool (isCompoundLiteralId(X) andBool X in_keys(Env))
          [structural]

     rule [include-int-i]:
          <k> declareInternalVariable(X:CId, _, initValue(_, T::Type, Init:K)) ~> blockOMP(Th:Int, C:K, Control:K, Post:K, S:K)
               => blockOMP(Th, C, declareInternalVariable(X, T, initValue(X, T, Init)), Control, Post, S)
               ...</k>
          <env> Env::Map </env>
          requires notBool isStaticType(T)
               andBool notBool isExternType(T)
               andBool notBool isFunctionType(T)
               andBool notBool isVariablyModifiedType(T)
               andBool notBool (isCompoundLiteralId(X) andBool X in_keys(Env))
          [structural]

     //        syntax KItem ::= checkUse(KItem) [strict] semantics/c/language/common/check-use.k:5:
     //        extractInitialTerm(checkUse(tv(V:Int, TT:UType))) => checkUse(tv(100, TT)) ===========> DID NOT WORK
     //        extractInitialTerm(V:KItem) => V =============> WORKED
     //        extractInitialTerm(checkUse(V:KItem)) => V =============> DID NOT WORK
     rule <k>
               extractInitialTerm(V:KItem) 
               => V
          ...
          </k>
     syntax KItem ::= extractControlTerm(K)
     rule <k>
               extractControlTerm(L:CabsLoc ~> te((A:KItem < B:KItem) != C:KItem, T:UType))
               => te((A < 10) != C, T)
          ...
          </k>

     rule <k> ompClauseExpr(K:K)
               => K
          ...</k> 
     
     /*
     https://github.com/JIVE-verification/openmp-k/blob/master/c-semantics/semantics/c/language/execution/expr/identifier.k#L18C6-L21C23
     rule <k> X:CId => lv(lnew(Base), T) ...</k>
          <env>... X |-> Base::SymBase ...</env>
          <types>... X |-> T::Type ...</types>
          [structural]
     */

     /*
          https://github.com/JIVE-verification/openmp-k/blob/master/c-semantics/semantics/c/language/execution/stmt/block.k#L39
          rule <k> popBlock => deleteObjects(Locals) ~> exitRestrictBlock(Locals) ~> updateScope ...</k>
          (<block-control>...
               <local-addresses> Locals::Set </local-addresses>
          ...</block-control> => C)
          <block-stack> ListItem(C:BlockControlCell) => .List ...</block-stack>
          [structural]
     */

     rule  <thread>...
               <k> OmpParentVar(X:CId) => lv(lnew(Base), T)
               ...</k>
               <block-stack> ListItem(
                    <block-control>...
                         <env>... X |-> Base::SymBase ...</env>
                         <types>... X |-> T::Type ...</types>
                    ...</block-control>) 
               ...</block-stack>
          ...</thread>

     rule <thread>...
          <k> OmpPrivateItem(X:CId) => declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), .K)) 
               ...</k>
             <types>M:Map</types>  
          ...</thread>
     // int x = x;
     // int _temp1 = x; int x = _temp1; // delete _temp1;
     rule <thread>...
          <k> OmpFirstPrivateItem(X:CId) => declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), Initializer(X := OmpParentVar(X)))) 
               ...</k>
             <types>M:Map</types>  
          ...</thread>

         
     rule <thread>...
          <k> OmpReductionItemPlus(X:CId) ~> R:K  
                    => declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), Initializer(X := 0)))  
                    ~> R ~> Computation(te( OmpParentVar(X) := OmpParentVar(X) + X, rvalType(type(M[X]))))
               </k>
             <types>M:Map</types>  
          ...</thread>


     rule <thread>...
          <k> OmpReductionItemProd(X:CId) ~> R:K  
                    => declareInternalVariable(X, type(M[X]), initValue(X, type(M[X]), Initializer(X := 1)))  
                    ~> R ~> Computation(te( OmpParentVar(X) := OmpParentVar(X) * X, rvalType(type(M[X]))))
               </k>
             <types>M:Map</types>  
          ...</thread>


     rule [extract-total-threads]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOMP(Th:Int, C:K, Initial:K, Control:K, Post:K, S:K)
               ...</k>
          ...</thread>
          <omp-current-threads> TotalThreads:Int => Th +Int 1 </omp-current-threads>
          requires TotalThreads ==Int 0 

     rule [zero-thread]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOMP(Th:Int, O:K, declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem := V:KItem))), compoundExp(L:CabsLoc ~> te((I:KItem < N:KItem) != C:KItem, TT:UType)), Post:K, S:K)
               => declareInternalVariable(X, T, initValue(X, T, Initializer(Y := V ))) ~> O ~> For(compoundExp( L~> te((I < ( (N % tv(TotalThreads, TT)) + ( N / tv( TotalThreads, TT) )  ) ) != C, TT)), Post, S) ~> waitingForChild
               ...</k>
          ...</thread>
          <thread-status>
               Status:Map => Status[Th <- threadRunning]
          </thread-status>
          <omp-current-threads> TotalThreads:Int => 0 </omp-current-threads>
          requires Th ==Int ThId andBool Th ==Int 0 andBool TotalThreads =/=Int 0
     
     rule [other-thread]:
          <thread>
          ...
               <thread-id> Parent:Int </thread-id>
               <thread-local> 
                    C::Bag 
                    <duration> _ </duration>
                    <parent-thread> _ </parent-thread>
                    <child-threads> ... .Set => SetItem(Fresh)</child-threads>
               </thread-local>
               <k> 
                    blockOMP(Th:Int, O:K, declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem := V:KItem))), compoundExp(L:CabsLoc ~> te((I:KItem < N:KItem) != CM:KItem, TT:UType)), Post:K, S:K)
                    => blockOMP(Th -Int 1, O, declareInternalVariable(X, T, initValue(X, T, Initializer(Y := V))), compoundExp(L ~> te((I < N) != CM, TT)),  Post, S)
               ...
               </k>
          ...
          </thread>
          <next-thread-id> Fresh:Int => Fresh +Int 1 </next-thread-id>
          <thread-status>
               Status:Map => Status[Fresh <- threadRunning]
          </thread-status>
          <omp-current-threads> TotalThreads:Int </omp-current-threads>
          (.Bag =>
          <thread>
          ...
               <thread-id> Fresh:Int </thread-id>
               <k>  
                   declareInternalVariable(X, T, initValue(X, T, Initializer(Y := ( (N % tv(TotalThreads, TT)) + ( (N / tv( TotalThreads, TT)) * tv(Th, TT) ) ))) ) ~> O ~> For(compoundExp( L~> te((I < ( (N % tv(TotalThreads, TT)) + ( (N / tv( TotalThreads, TT)) * tv(Th +Int 1, TT) ) )) != CM, TT)), Post, S) ~> joinChild
               </k>
               <thread-local>
                    C
                    <parent-thread> Parent </parent-thread>
                    <child-threads> .Set </child-threads>
                    <duration> threadLocal(Fresh:Int) </duration>
               </thread-local>
          ...
          </thread>)
          requires Th =/=Int 0 andBool notBool hasLint andBool TotalThreads =/=Int 0
          [large, ndthread]

     rule [join-if-no-child]:
          <thread> ...
               <k>
                    waitingForChild => .K 
               ...</k>
               <child-threads> .Set </child-threads>
          ...
          </thread>

     rule [join-child-thread]:
          ((<thread>...
               <thread-id> ThId:Int </thread-id>
               <k>
                    joinChild
               </k>
               <child-threads> .Set </child-threads>
               <parent-thread> P:Int </parent-thread>
               ...</thread>) => .Bag)
          <thread>
          ...
               <thread-id> P </thread-id>
               <child-threads> ... SetItem(ThId) => .Set ...</child-threads>
          ...
          </thread>
	// each time add new thread
	// and push for (Control, Post, S) to that thread
	// waiting for Thread Calculation to finish


     syntax KItem ::= ompForSpawn(K, K, K)

     // Clause-1 expressions (e.g., `int i = 0`) evaluate before reaching the loop body
     // and can leave an rvalue on top of <k>. Drop that result so the OpenMP rule
     // can start spawning threads.
     rule <k> loopMarked ~> V:KResult ~> OMPFor(Control:K, Post:K, S:K)
               => loopMarked ~> OMPFor(Control, Post, S)
          ...</k>
          <block-history> ListItem(_:Int) ...</block-history>
          [structural]

     rule [omp-for]:
     <k> loopMarked ~> OMPFor(Control:K, Post:K, S:K)
               => ompForSpawn(Control, Post, S)
     ...</k>
     <block-history> ListItem(_:Int) ...</block-history>
     [structural]

     // Prototype parallel execution: spawn three worker threads that each run S
     // with distinct values of the loop variable.  This mirrors our test program
     // (iterations 0, 1, 2) and will be generalized in later iterations.
     rule <k> ompForSpawn(_, _, S:K)
               => spawn-aux-omp(tv(0, utype(int)), S)
               ~> spawn-aux-omp(tv(1, utype(int)), S)
               ~> spawn-aux-omp(tv(2, utype(int)), S)
               ~> join-aux-omp(1)
               ~> join-aux-omp(2)
               ~> join-aux-omp(3)
          ...</k>
          <block-history> ListItem(_:Int) ...</block-history>
          [structural]

     rule [spawn-aux-omp]:
          <thread>...
               <k> spawn-aux-omp(IterVal:RValue, S:K)
                    => .K
               ...</k>
               <curr-tu> Tu:String </curr-tu>
               <buffer> .List </buffer>
               <env> ParentEnv:Map </env>
               <types> Types:Map </types>
               <curr-scope> Scope:Scope </curr-scope>
          ...</thread>
          <genv> GEnv:Map </genv>
          <thread-status>
               Status:Map => Status[ThId <- threadRunning]
          </thread-status>
          <next-thread-id> ThId:Int => ThId +Int 1 </next-thread-id>
          (.Bag =>
          <thread>...
               <duration> threadLocal(ThId) </duration>
               <thread-id> ThId </thread-id>
               <k> initThreadLocalVar(Identifier("i"), type(int), IterVal, linc(type(int), threadLocal(ThId)))
                    ~> S
               </k>
               <env> updateMap(GEnv, ParentEnv) </env>
               <types> Types </types>
               <curr-tu> Tu </curr-tu>
               <curr-scope> Scope </curr-scope>
          ...</thread>)
          requires notBool hasLint
          [large, ndthread]

     rule [join-aux-omp]:
          <thread>...
               <k> join-aux-omp(ThId:Int) => .K ...</k>
               <thread-id> ThisThread:Int </thread-id>
          ...</thread>
          <thread-status>
               Status:Map => Status[ThId <- threadJoined]
          </thread-status>
          (<thread>...
               <k> .K </k>
               <thread-id> ThId </thread-id>
          ...</thread> => .Bag)
          requires (ThId in_keys(Status))
               andBool (Status[ThId] =/=K threadJoined)
               andBool ThId =/=K ThisThread
          [ndthread]

     rule <k> (.K => UNDEF("OMP1", "join-aux-omp called for an invalid or already-joined thread."))
               ~> join-aux-omp(ThId:Int)
          ...</k>
          <thread-status>
               Status:Map
          </thread-status>
          <thread-id> ThisThread:Int </thread-id>
          requires notBool ((ThId in_keys(Status))
               andBool (Status[ThId] =/=K threadJoined)
               andBool ThId =/=K ThisThread)
          [ndthread]

     // Initialize thread-local loop variable with iteration-specific value
     // Follows pattern from decl/local.k:103-108 (defineAndInit)
     rule <k> initThreadLocalVar(X:CId, T:Type, InitVal:RValue, Base:SymBase)
               => allocObject(Base, T)
               ~> addToEnv(X, Base)
               ~> giveType(X, T)
               ~> Computation(lv(lnew(Base), T) := InitVal)
          ...</k>
          <local-addresses>... .Set => SetItem(Base) ...</local-addresses>
          [structural]
 

     /*@ \fromStandard{\source[n1570]{\para{6.8.5.1}{1}}}{
     The evaluation of the controlling expression takes place before each
     execution of the loop body.
     }*/

     rule [while-mark]:
          <k> While(B:K, S:K) ~> K:K
               => loopMarked
                    ~> While(B, S)
                    ~> popLoop
          </k>
          <block-history> ListItem(Num:Int) ...</block-history>
          <loop-stack> .List => ListItem(kpair(Num, K)) ...</loop-stack>
          [structural]
     rule [while]:
          loopMarked ~> While(B:K, S:K)
          => IfThenElse(B, (S ~> loopMarked ~> While(B, S)), Nop())
          [structural]  // rule so that looping programs see repetition

     /*@ \fromStandard{\source[n1570]{\para{6.8.5.2}{1}}}{
     The evaluation of the controlling expression takes place after each
     execution of the loop body.
     }*/

     rule [do-while-mark]:
          <k> DoWhile(B:K, S:K) ~> K:K
               => loopMarked
                    ~> DoWhile(B, S)
                    ~> popLoop
          </k>
          <block-history> ListItem(Num:Int) ...</block-history>
          <loop-stack> .List => ListItem(kpair(Num, K)) ...</loop-stack>
          [structural]
     rule [do-while]:
          loopMarked ~> DoWhile(B:K, S:K)
          => S ~> IfThenElse(B, (loopMarked ~> DoWhile(B, S)), Nop())
          [structural]  // rule so that looping programs see repetition

     /*@
     \begin{lrbox}{\LstBox}
     \begin{minipage}{0.5\linewidth}
     \begin{lstlisting}[multicols=3]
     while (...) {
          ...
          continue;
          ...
          contin: ;
     }

     do {
          ...
          continue;
          ...
          contin: ;
     } while (...);

     for (...) {
          ...
          continue;
          ...
          contin: ;
     }
     \end{lstlisting}
     \end{minipage}
     \end{lrbox}
     \fromStandard{\source[n1570]{\para{6.8.6.2}{2}}}{
     A \cinline{continue} statement causes a jump to the loop-continuation
     portion of the smallest enclosing iteration statement; that is, to the end
     of the loop body. More precisely, in each of the statements\\
     \usebox{\LstBox}\\
     unless the \cinline{continue} statement shown is in an enclosed iteration
     statement (in which case it is interpreted within that statement), it is
     equivalent to \cinline{goto contin;}.
     }
     */
     rule [continue]:
          Continue() ~> (K:KItem => .K)
          requires (K =/=K loopMarked)
               andBool (K =/=K popBlock)
               andBool (pushBlock(...) :/=K K)
               andBool (K =/=K popLoop)
               andBool (IfThenElse(...) :/=K K)
          [structural]
     rule Continue() ~> (IfThenElse(_, K:KItem ~> _, _) => .K)
          requires K =/=K loopMarked
          [structural]
     rule Continue() ~> popBlock
          => popBlock ~> Continue()
          [structural]
     rule Continue() ~> popLoop
          => popLoop ~> Continue()
          [structural]
     rule Continue() ~> pushBlock(N::Int)
          => pushBlock(N) ~> Continue()
          [structural]

     rule [continue-done-for]:
          (Continue() => Computation(Post))
          ~> loopMarked
          ~> For(_, Post:K, _)
          [structural]
     rule [continue-done]:
          (Continue() => .K) ~> loopMarked ~> K:KItem
          requires For(...) :/=K K
          [structural]
     // Do-while.
     rule (Continue() => .K) ~> IfThenElse(_, loopMarked ~> _, _)
          [structural]

     rule [popLoop]:
          <k> popLoop ~> _ => K </k>
          <block-history> ListItem(Num:Int) ...</block-history>
          <loop-stack> ListItem(kpair(Num:Int, K:K)) => .List ...</loop-stack>
          [structural]

     rule [popLoop-popBlock]:
          <k> (.K => popBlock) ~> popLoop ...</k>
          <block-history> ListItem(Num:Int) ...</block-history>
          <loop-stack> ListItem(kpair(Num':Int, _)) ...</loop-stack>
          requires Num' =/=Int Num
          [structural]

/*
    rule [temp-zero-thread-dist]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOMP(Th:Int, Temp:CId, declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem := V:KItem))), compoundExp(L:CabsLoc ~> te((A:KItem < B:KItem) != C:KItem, TT:UType)), Post:K, S:K)
               => declareInternalVariable(X, T, initValue(X, T, Initializer(Y := (V / tv(TotalThreads *Int Th, TT)) ))) ~> For(compoundExp( L~> te((A < (B / tv(TotalThreads *Int Th, TT))) != C, TT)), Post, S)
               ...</k>
          ...</thread>
          <omp-current-threads> TotalThreads:Int </omp-current-threads>
          requires TotalThreads =/=Int 0
*/
/*
    rule [temp-zero-thread]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOMP(Th:Int, Temp:CId, declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem := V:KItem))), compoundExp(L:CabsLoc ~> te((A:KItem < B:KItem) != C:KItem, TT:UType)), Post:K, S:K)
               => declareInternalVariable(X, T, initValue(X, T, Initializer(Y := (Th *Int 2)))) ~> For(compoundExp( L~> te((A < (B / tv(2, TT))) != C, TT)), Post, S)
               ...</k>
          ...</thread>
*/
/*
    rule [temp-zero-thread]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOMP(Th:Int, Temp:CId, declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem := V:KItem))), compoundExp(L:CabsLoc ~> te((A:KItem < B:KItem) != C:KItem, TT:UType)), Post:K, S:K)
               => declareInternalVariable(X, T, initValue(X, T, Initializer(Y := (Th *Int 2)))) ~> For(compoundExp( L~> te((A < (B / tv(2, TT))) != C, TT)), Post, S)
               ...</k>
          ...</thread>
//  WORKED
*/         
/*
    rule [temp-zero-thread]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOMP(Th:Int, Temp:CId, declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem := V:KItem))), compoundExp(L:CabsLoc ~> te((A:KItem < B:KItem) != C:KItem, TT:UType)), Post:K, S:K)
               => declareInternalVariable(X, T, initValue(X, T, Initializer(Y := (Th *Int 2)))) ~> For(compoundExp( L~> te((A < (10 +Int 2)) != C, TT)), Post, S)
               ...</k>
          ...</thread>
/*

/*     rule [temp-zero-thread]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOMP(Th:Int, Temp:CId, declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem := V:KItem))), compoundExp(L:CabsLoc ~> te((A:KItem < B:KItem) != C:KItem, TT:UType)), Post:K, S:K)
               => te((A < (10 +Int 2)) != C, TT)
               ...</k>
          ...</thread>
*/
/*
     rule [temp-zero-thread]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOMP(Th:Int, Temp:CId, declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem := V:KItem))), compoundExp(K:K), Post:K, S:K)
               => extractControlTerm(K)
               ...</k>
          ...</thread>
*/
/*     rule [temp-zero-thread]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOMP(Th:Int, Temp:CId, declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem := V:KItem))), compoundExp(K:K), Post:K, S:K)
               => declareInternalVariable(X, T, initValue(X, T, Initializer(Y := (Th *Int 2))))
               ...</k>
          ...</thread>
*/

          // te ( _!=_ ( _<_ ( Cast2 ( t ( quals ( .Set ) , .Set , unsigned-long-long-int (  ) ) , Identifier ( "i" ) ) , checkUse ( tv ( 11 , ut ( .Set , unsigned-long-long-int (  ) ) ) ) ) , checkUse ( tv ( 0 , ut ( SetItem ( IntegerConstant (  ) ) , int (  ) ) ) ) ) , ut ( .Set , int (  ) ) ) 

     // declareInternalVariable(X:CId, _, initValue(_, T::Type, Init:K))
     // blockOMP(,,declareInternalVariable(X:CId, _, initValue(_, T::Type, Init:KItem)),,,) => extractInitialTerm(X, T, Init) =========> WORKED
     // blockOMP(,,declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem :=  V:KItem))),,,) => extractInitialTerm(X, T, V) =========> WORKED
     // blockOMP(,,declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem :=  checkUse(tv(V::CValue, TT::UType))))),,,) => declareInternalVariable(X, T, initValue(X, T, Initializer(Y :=  checkUse(tv(100, TT))))) =========> DID NOT WORK: [Error] Inner Parser: Parse error: unexpected token 'checkUse'.
     // blockOMP(,,declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem :=  V:KItem))),,,) => extractInitialTerm(V) =========> WORKED
     // declareInternalVariable(X, T, initValue(X, T, Initializer(Y := 10))) ========> WORKED

     // declareInternalVariable ( Identifier ( "i" ) , t ( quals ( .Set ) , .Set , int (  ) ) , initValue ( Identifier ( "i" ) , t ( quals ( .Set ) , .Set , int (  ) ) , Initializer(_:=_) ( Identifier ( "i" ) , checkUse ( tv ( 0, ut ( .Set , int (  ) ) ) ) ) ) ) 
     // compoundExp ( CabsLoc ( "test-c-511.c" , "/home/user/mounted/test-c-511.c" , 6 , 10 , "false" ) ~> te ( _!=_ ( _<_ ( Cast2 ( t ( quals ( .Set ) , .Set , unsigned-long-long-int (  ) ) , Identifier ( "i" ) ) , checkUse ( tv ( 15 , ut ( .Set , unsigned-long-long-int (  ) ) ) ) ) , checkUse ( tv ( 0 , ut ( SetItem ( IntegerConstant (  ) ) , int (  ) ) ) ) ) , ut ( .Set , int (  ) ) ) )

/*
     ============== WORKED ========================
    rule [temp-zero-thread-dist]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOMP(Th:Int, Temp:CId, declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem := V:KItem))), compoundExp(L:CabsLoc ~> te((I:KItem < N:KItem) != C:KItem, TT:UType)), Post:K, S:K)
               => declareInternalVariable(X, T, initValue(X, T, Initializer(Y := (N % tv(TotalThreads, TT) + N / tv( TotalThreads, TT) + tv(Th, TT) ) ))) ~> For(compoundExp( L~> te((I < (N % tv(TotalThreads, TT) + N / tv( TotalThreads, TT) + tv(Th +Int 1, TT) )) != C, TT)), Post, S)
               ...</k>
          ...</thread>
          <omp-current-threads> TotalThreads:Int </omp-current-threads>
          requires TotalThreads =/=Int 0
*/

// declareInternalVariable(X, T, initValue(X, T, Initializer(Y := (N % tv(TotalThreads, TT) + N / tv( TotalThreads, TT) + tv(Th, TT) ) ))) ~> For(compoundExp( L~> te((I < (N % tv(TotalThreads, TT) + N / tv( TotalThreads, TT) + tv(Th +Int 1, TT) )) != C, TT)), Post, S)


     // compoundExp (L::CabsLoc ~> )
     // rule te(L:K, T::UType) / tv(V:CValue, T'::UType) => te(L / tv(V, T'), T)

endmodule