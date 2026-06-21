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
    
     syntax KItem ::= "waitingForChild"
     syntax KItem ::= "joinChild"
     syntax KItem ::= "handleInitOmpThreadPrivate"
     syntax KItem ::= "extractToInitOmpThreadPrivate"
     syntax KItem ::= "extractToUpdateOmpThreadPrivate"
     syntax KItem ::= "handleToUpdateOmpThreadPrivate"

     syntax KItem ::= OmpThreadPrivate(CId)

     
     syntax KItem ::= extractInitialTerm(KItem)

     // joining OMP Thread with Id:Int 
     syntax KItem ::= joinOmpThread(Int)
     
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

     rule [include-parallel-omp-i]:
               <k> Computation(te(X:CId := V:KItem, TT::UType)) ~> blockOMP(Th:Int, B:K, A:K, Control:K, Post:K, S:K)
                    => blockOMP(Th, B:K, A:K, declareInternalVariable ( X , type(TypesMap[X]) , initValue ( X , type(TypesMap[X]) , Initializer( X:=V) )), Control, Post, S)
                    ...</k>
               <env> Env::Map </env>
               <types> TypesMap::Map </types>
         requires notBool isStaticType(type(TypesMap[X]))
               andBool notBool isExternType(type(TypesMap[X]))
               andBool notBool isFunctionType(type(TypesMap[X]))
               andBool notBool isVariablyModifiedType(type(TypesMap[X]))
               andBool notBool (isCompoundLiteralId(X) andBool X in_keys(Env))
          [structural]

     rule [include-parallel-omp-int-i]:
          <k> declareInternalVariable(X:CId, _, initValue(_, T::Type, Init:K)) ~> blockOMP(Th:Int, B:K, A:K, Control:K, Post:K, S:K)
               => blockOMP(Th, B:K, A:K, declareInternalVariable(X, T, initValue(X, T, Init)), Control, Post, S)
               ...</k>
          <env> Env::Map </env>
          requires notBool isStaticType(T)
               andBool notBool isExternType(T)
               andBool notBool isFunctionType(T)
               andBool notBool isVariablyModifiedType(T)
               andBool notBool (isCompoundLiteralId(X) andBool X in_keys(Env))
          [structural]

     rule [include-ompfor-i]:
               <k> Computation(te(X:CId := V:KItem, TT::UType)) ~> blockOmpFor(B:K, A:K, Control:K, Post:K, S:K)
                    => blockOmpFor(B:K, A:K, declareInternalVariable ( X , type(TypesMap[X]) , initValue ( X , type(TypesMap[X]) , Initializer( X:=V) )), Control, Post, S)
                    ...</k>
               <env> Env::Map </env>
               <types> TypesMap::Map </types>
         requires notBool isStaticType(type(TypesMap[X]))
               andBool notBool isExternType(type(TypesMap[X]))
               andBool notBool isFunctionType(type(TypesMap[X]))
               andBool notBool isVariablyModifiedType(type(TypesMap[X]))
               andBool notBool (isCompoundLiteralId(X) andBool X in_keys(Env))
          [structural]

     rule [include-omp-for-int-i]:
          <k> declareInternalVariable(X:CId, _, initValue(_, T::Type, Init:K)) ~> blockOmpFor(B:K, A:K, Control:K, Post:K, S:K)
               => blockOmpFor(B:K, A:K, declareInternalVariable(X, T, initValue(X, T, Init)), Control, Post, S)
               ...</k>
          <env> Env::Map </env>
          requires notBool isStaticType(T)
               andBool notBool isExternType(T)
               andBool notBool isFunctionType(T)
               andBool notBool isVariablyModifiedType(T)
               andBool notBool (isCompoundLiteralId(X) andBool X in_keys(Env))
          [structural]

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

     rule <k> BeforeOmp(K:K)
               => K
          ...</k> 

     rule <k> AfterOmp(K:K)
               => K
          ...</k> 

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

     // if identifier X is global, declare an internal variable with X
     rule  <thread>...
               <k> OmpThreadPrivate(X:CId) => declareInternalVariable(X, type(Types[X]), initValue(X, type(Types[X]), Initializer(X := OmpGlobalVar(X))))
               ...</k>
               <block-control>... 
                    <env>... X |-> Base::SymBase ...</env> 
               ...</block-control>
          ...</thread>
          <external-types>Types:Map</external-types>
          requires isStaticDuration(Base)
          
     // if identifier X is not global, ignore declaring a private copy of that 
     rule  <thread>...
               <k> OmpThreadPrivate(X:CId) => .K
               ...</k>
                    <block-control>... 
                         <env>... X |-> Base::SymBase ...</env> 
                    ...</block-control>
          ...</thread>
          <external-types>Types:Map</external-types>
          requires notBool isStaticDuration(Base)

     rule  <thread>...
               <k> OmpGlobalVar(X:CId) => lv(lnew(Base), T)
               ...</k>
          ...</thread>
          <external-types>... X |-> T::Type ...</external-types>
          <external-defs>... X |-> Base::SymBase ...</external-defs>

     
     rule <k>
          blockOmpSection(S:K) => S
          ...</k>


     rule [extract-total-threads-ompfor]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOMP(Th:Int, B:K, A:K, Initial:K, Control:K, Post:K, S:K)
               ...</k>
          ...</thread>
          <omp-current-threads> TotalThreads:Int => Th +Int 1 </omp-current-threads>
          requires TotalThreads ==Int 0 

     rule [extract-total-threads-omp-parallel]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOmpParallel(Th:Int, B:K, A:K, S:K)
               ...</k>
          ...</thread>
          <omp-current-threads> TotalThreads:Int => Th +Int 1 </omp-current-threads>
          requires TotalThreads ==Int 0


     rule [extract-total-threads-omp-parallel-sections]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOmpParallelSections(Th:Int, B:K, A:K, S:K)
               ...</k>
          ...</thread>
          <omp-current-threads> TotalThreads:Int => Th +Int 1 </omp-current-threads>
          requires TotalThreads ==Int 0


     rule [zero-threadomp-parallel-for]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOMP(Th:Int, B:K, A:K, declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem := V:KItem))), compoundExp(L:CabsLoc ~> te((I:KItem < N:KItem) != C:KItem, TT:UType)), Post:K, S:K)
               => B ~> declareInternalVariable(X, T, initValue(X, T, Initializer(Y := V ))) ~> For(compoundExp( L~> te((I < ( (N % tv(TotalThreads, TT)) + ( N / tv( TotalThreads, TT) )  ) ) != C, TT)), Post, S) ~> A ~> waitingForChild
               ...</k>
          ...</thread>
          <thread-status>
               Status:Map => Status[Th <- threadRunning]
          </thread-status>
          <omp-current-threads> TotalThreads:Int</omp-current-threads>
          requires Th ==Int ThId andBool Th ==Int 0 andBool TotalThreads =/=Int 0
//          <omp-current-threads> TotalThreads:Int => 0 </omp-current-threads>

     rule [thread-omp-for]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOmpFor(B:K, A:K, declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem := V:KItem))), compoundExp(L:CabsLoc ~> te((I:KItem < N:KItem) != CM:KItem, TT:UType)), Post:K, S:K)
               => B ~> declareInternalVariable(X, T, initValue(X, T, Initializer(Y := ( (N % tv(TotalThreads, TT)) + ( (N / tv( TotalThreads, TT)) * tv(ThId, TT) ) ))) ) ~> For(compoundExp( L~> te((I < ( (N % tv(TotalThreads, TT)) + ( (N / tv( TotalThreads, TT)) * tv(ThId +Int 1, TT) ) )) != CM, TT)), Post, S) ~> A
               ...</k>
          ...</thread>
          <omp-current-threads> TotalThreads:Int</omp-current-threads>
          requires TotalThreads =/=Int 0
//          <omp-current-threads> TotalThreads:Int => 0 </omp-current-threads>

     rule [zero-threadomp-parallel]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOmpParallel(Th:Int, B:K, A:K, S:K)
               => extractToInitOmpThreadPrivate ~> B ~> S ~> A ~> waitingForChild ~> extractToUpdateOmpThreadPrivate
               ...</k>
          ...</thread>
          <thread-status>
               Status:Map => Status[Th <- threadRunning]
          </thread-status>
          <omp-current-threads> TotalThreads:Int</omp-current-threads>
          requires Th ==Int ThId andBool Th ==Int 0 andBool TotalThreads =/=Int 0

     rule [zero-threadomp-parallel-sections]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOmpParallelSections(Th:Int, B:K, A:K, list(S:List))
               => extractToInitOmpThreadPrivate ~> B ~> listToK(S) ~> A ~> waitingForChild ~> extractToUpdateOmpThreadPrivate
               ...</k>
          ...</thread>
          <thread-status>
               Status:Map => Status[Th <- threadRunning]
          </thread-status>
          <omp-current-threads> TotalThreads:Int</omp-current-threads>
          requires Th ==Int ThId andBool Th ==Int 0 andBool TotalThreads =/=Int 0

     rule [other-thread-omp-parallel-for]:
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
                    blockOMP(Th:Int, B:K, A:K, declareInternalVariable(X:CId, _, initValue(_, T::Type, Initializer(Y:KItem := V:KItem))), compoundExp(L:CabsLoc ~> te((I:KItem < N:KItem) != CM:KItem, TT:UType)), Post:K, S:K)
                    => blockOMP(Th -Int 1, B:K, A:K, declareInternalVariable(X, T, initValue(X, T, Initializer(Y := V))), compoundExp(L ~> te((I < N) != CM, TT)),  Post, S)
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
                   B ~> declareInternalVariable(X, T, initValue(X, T, Initializer(Y := ( (N % tv(TotalThreads, TT)) + ( (N / tv( TotalThreads, TT)) * tv(TotalThreads -Int Th, TT) ) ))) ) ~> For(compoundExp( L~> te((I < ( (N % tv(TotalThreads, TT)) + ( (N / tv( TotalThreads, TT)) * tv(TotalThreads -Int Th +Int 1, TT) ) )) != CM, TT)), Post, S) ~> A ~> joinChild
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

     rule [other-thread-omp-parallel]:
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
                    blockOmpParallel(Th:Int, B:K, A:K,  S:K)
                    => blockOmpParallel(Th -Int 1, B:K, A:K, S)
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
                   extractToInitOmpThreadPrivate ~> B ~> S ~> A ~> joinChild
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

     rule [other-thread-omp-parallel-sections-not-empty-sections]:
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
                    blockOmpParallelSections(Th:Int, B:K, A:K,  list(ListItem(S1:KItem) LL:List))
                    => blockOmpParallelSections(Th -Int 1, B:K, A:K, list(LL))
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
                   extractToInitOmpThreadPrivate ~> B ~> S1 ~> A ~> joinChild
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

     rule [other-thread-omp-parallel-sections-empty-sections]:
          <thread>
          ...
               <thread-id> Parent:Int </thread-id>
               <k> 
                    blockOmpParallelSections(Th:Int, B:K, A:K,  list(.List))
                    => blockOmpParallelSections(Th -Int 1, B:K, A:K, list(.List))
               ...
               </k>
          ...
          </thread>
          <omp-current-threads> TotalThreads:Int </omp-current-threads>
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
// 

     rule [update-last-private-if-last-iteration]:
          <thread> ...
               <thread-id> ThId:Int</thread-id>
               <k>
                    OmpLastPrivateItem(X:CId) => Computation(te(OmpParentVar(X) := OmpParentVar(X) + X, rvalType(T)))
               ...</k>
               <thread-local>
               ...
                    <function-control>
                    ...
                         <block-control>...
                         <env>... X |-> Base::SymBase ...</env>
                         <types>... X |-> T::Type ...</types>
                         ...</block-control>
                    ...
                    </function-control>
               ...
               </thread-local>
          ...
          </thread>
          <omp-current-threads> TotalThreads:Int </omp-current-threads>
          requires ThId ==Int (TotalThreads -Int 1)

     rule [ignore-last-private-if-last-iteration]:
          <thread> ...
               <thread-id> ThId:Int</thread-id>
               <k>
                    OmpLastPrivateItem(X:CId) => .K
               ...</k>
               <thread-local>
               ...
                    <function-control>
                    ...
                         <block-control>...
                         <env>... X |-> Base::SymBase ...</env>
                         <types>... X |-> T::Type ...</types>
                         ...</block-control>
                    ...
                    </function-control>
               ...
               </thread-local>
          ...
          </thread>
          <omp-current-threads> TotalThreads:Int </omp-current-threads>
          requires ThId =/=Int (TotalThreads -Int 1)

     rule [extract-thread-private-init]:
          <thread> ...
               <k>
                    extractToInitOmpThreadPrivate ~> R:K
                    => handleInitOmpThreadPrivate ~> R
               </k>
               <thread-local>
               ...
                    <omp-local-thread-private> L:List => keys_list(ThdPrvt)</omp-local-thread-private>
               ...
               </thread-local>
          ...
          </thread>
          <omp-global-thread-private> ThdPrvt:Map </omp-global-thread-private>
     
     rule [extract-thread-private-update]:
          <thread> ...
               <k>
                    extractToUpdateOmpThreadPrivate ~> R:K
                    => handleToUpdateOmpThreadPrivate ~> R
               </k>
               <thread-local>
               ...
                    <omp-local-thread-private> L:List => keys_list(ThdPrvt)</omp-local-thread-private>
               ...
               </thread-local>
          ...
          </thread>
          <omp-global-thread-private> ThdPrvt:Map </omp-global-thread-private>

     rule [handle-thread-private-init-not-empty-directbase]:
          <thread>...
               <thread-id> ThId:Int</thread-id>
               <k>
                    handleInitOmpThreadPrivate ~> (.K => OmpThreadPrivate(X))
               ...</k>
               <thread-local>
               ...
                    <env> ... X |-> Base:SymBase </env>
                    <omp-local-thread-private> ( ListItem(X:CId) => .List) L:List</omp-local-thread-private>
               ...
               </thread-local>
          ...
          </thread>
          requires isStaticDuration(Base) 

     rule [handle-thread-private-init-not-empty-systembase]:
          <thread>...
               <thread-id> ThId:Int</thread-id>
               <k>
                    handleInitOmpThreadPrivate
               ...</k>
               <thread-local>
               ...
                    <env> ... X |-> Base:SymBase </env>
                    <omp-local-thread-private> ( ListItem(X:CId) => .List) L:List</omp-local-thread-private>
               ...
               </thread-local>
          ...
          </thread>
          requires notBool isStaticDuration(Base)
     
     rule [handle-thread-private-init-empty]:
          <thread>...
               <thread-id> ThId:Int</thread-id>
               <k>
                    handleInitOmpThreadPrivate => .K
               ...</k>
               <thread-local>
               ...
                    <omp-local-thread-private> .List</omp-local-thread-private>
               ...
               </thread-local>
          ...
          </thread>

     rule [handle-thread-private-update-not-empty-directbase]:
          <thread>...
               <thread-id> ThId:Int</thread-id>
               <k>
                    handleToUpdateOmpThreadPrivate ~> (.K => Computation(te(OmpGlobalVar(X) := X, rvalType(T))))
               ...</k>
               <thread-local>
               ...
                    <omp-local-thread-private> ( ListItem(X:CId) => .List) L:List</omp-local-thread-private>
                    <block-stack> ListItem(
                         <block-control>...
                              <env>... X |-> Base::SymBase ...</env>
                         ...</block-control>) 
                    ...</block-stack>
               ...
               </thread-local>
          ...
          </thread>
          <external-types>... X |-> T::Type ...</external-types> 
          requires isStaticDuration(Base)

     rule [handle-thread-private-update-not-empty-systembase]:
          <thread>...
               <thread-id> ThId:Int</thread-id>
               <k>
                    handleToUpdateOmpThreadPrivate
               ...</k>
               <thread-local>
               ...
                    <omp-local-thread-private> ( ListItem(X:CId) => .List) L:List</omp-local-thread-private>
                    <block-stack> ListItem(
                         <block-control>...
                              <env>... X |-> Base::SymBase ...</env>
                         ...</block-control>) 
                    ...</block-stack>
               ...
               </thread-local>
          ...
          </thread>
          <external-types>... X |-> T::Type ...</external-types> 
          requires notBool isStaticDuration(Base)

     rule [handle-thread-private-update-empty]:
          <thread>...
               <thread-id> ThId:Int</thread-id>
               <k>
                    handleToUpdateOmpThreadPrivate => .K
               ...</k>
               <thread-local>
               ...
                    <omp-local-thread-private> .List</omp-local-thread-private>
               ...
               </thread-local>
          ...
          </thread>
     

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

endmodule