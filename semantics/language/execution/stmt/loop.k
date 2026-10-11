module C-STMT-LOOP
     imports C-SYNTAX
     imports C-DYNAMIC-SYNTAX
     imports C-TYPING-SYNTAX
     imports C-ENV-SYNTAX
     imports COMPAT-SYNTAX

     syntax KItem ::= "waitingForChild"
     syntax KItem ::= "joinChild"

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

     //  fixme fishy interaction with continue i think
     rule [for-mark]:
          <k> For(Control:K, Post:K, S:K) ~> K:K
               => loopMarked
               ~> For((#if Control =/=K emptyValue
                    #then Control
                    #else tv(1, t(.Set, int)) #fi),
                    Post, S)
               ~> popLoop
          </k>
          <block-history> ListItem(Num:Int) ...</block-history>
          <loop-stack> .List => ListItem(kpair(Num, K)) ...</loop-stack>
          [structural]

     rule [for]:
          <k> loopMarked ~> For(Control:K, Post:K, S:K)
               => IfThenElse(Control,
                    (S ~> Computation(Post) ~> loopMarked
                    ~> For(Control, Post, S)), Nop)
          ...</k>
          <block-history> ListItem(_:Int) ...</block-history>
          [structural] // rule so that looping programs see repetition

     rule [include-omp-parallel-for-int-i]:
          <k> declareInternalVariable(X:CId, _, initValue(_, T:Type, Init:K)) ~> blockOmpParallelFor(Th:Int, B:K, A:K, Control:K, Post:K, S:K)
               => blockOmpParallelFor(Th, B:K, A:K, declareInternalVariable(X, T, initValue(X, T, Init)), Control, Post, S)
               ...</k>
          <env> Env::Map </env>
          [structural]
          
     // @omp thread interleaving

//     rule interleave => .K [threadleave]
//   when it encounters interleave, it will order   
///*
     rule [record-execution-order]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> interleave => .K 
               ...</k>
          <curr-program-loc>
          CabsLoc ( _ , LineNo:Int , _ , _ )
          </curr-program-loc>
          ...</thread>
          <thread-exec-order> S:String => S +String "T" +String Int2String(ThId) +String "L" +String Int2String(LineNo) </thread-exec-order>
          [threadleave]
//*/
     /*syntax K ::= putInterleavePoints(K, K)[function]

     rule putInterleavePoints(.K, .K) => .K
     rule putInterleavePoints(.K, K1:KItem) => putInterleavePoints(interleave ~> K1, .K)
     rule putInterleavePoints(.K, K1:KItem ~> T:K) => putInterleavePoints(interleave ~> K1, T)
     rule putInterleavePoints(K1:K, K2:KItem ~> T:K) => putInterleavePoints(K1 ~> interleave ~> K2, T)
     rule putInterleavePoints(K1:K, K2:KItem) => putInterleavePoints(K1 ~> interleave ~> K2, .K)
     rule putInterleavePoints(K1:K, .K) => K1
     */
     
     rule [extract-total-threads-omp-parallel]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOmpParallel(Th:Int, B:K, A:K, S:K) => blockOmpParallel(Th, B, A, S) 
               ...</k>
          ...</thread>
          <omp-current-threads> TotalThreads:Int => Th +Int 1 </omp-current-threads>
          requires TotalThreads ==Int 0

     rule [extract-total-threads-omp-parallel-for]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOmpParallelFor(Th:Int, B:K, A:K, Initial:K, Control:K, Post:K, S:K)
               ...</k>
          ...</thread>
          <omp-current-threads> TotalThreads:Int => Th +Int 1 </omp-current-threads>
          requires TotalThreads ==Int 0 

     rule [zero-thread-omp-parallel]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOmpParallel(Th:Int, B:K, A:K, S:K)
               => B ~> S ~> A ~> waitingForChild 
               ...</k>
          ...</thread>
          <omp-current-threads> TotalThreads:Int</omp-current-threads>
          requires Th ==Int ThId andBool Th ==Int 0 andBool TotalThreads =/=Int 0

// blockOmpParallelFor ( 1 , BeforeOmp (_) , AfterOmp ( _) , declareInternalVariable ( Identifier ( "i" ) , t ( .Set , int ) , initValue ( Identifier ( "i" ) , t (.Set , int ) , Computation ( te ( Identifier ( "i" ) := tv ( 0 , t ( .Set , int ) ) , t ( .Set , int ) ) ) ) ) , te ( Identifier ( "i" ) <= tv ( 5 , t ( .Set , int ) ) != tv ( 0 , t ( SetItem ( IntegerConstant ) , int ) ) , t ( .Set , int ) ) , Post:K , S:K )

/*     rule [other-thread-omp-parallel-for-test]:
          <thread>
          ...
               <thread-id> Parent:Int </thread-id>
               <k> 
                    blockOmpParallelFor(Th:Int, B:K, A:K, declareInternalVariable(X:CId, _, initValue(_, T:Type, Computation(te(Y:KItem := V:KItem, _)))), te(I:KItem < N:KItem != CM:KItem, TT:Type), Post:K, S:K)
                    => jive ~> Computation(te( Y := V, T))
               ...
               </k>
          ...
          </thread>
*/

///*
     rule [zero-thread-omp-parallel-for]:
          <thread>...
          <thread-id> ThId:Int </thread-id>
          <k> blockOmpParallelFor(Th:Int, B:K, A:K, declareInternalVariable(X:CId, _, initValue(_, T:Type, Computation(te( Y:KItem := V:KItem, _)))), te((I:KItem < N:KItem) != CM:KItem, TT:Type), Post:K, S:K)
               => B ~> declareInternalVariable(X, T, initValue(X, T, Computation(te( Y := V, T)))) ~> For(te((I <((N % tv(TotalThreads, TT)) + ( N / tv( TotalThreads, TT) )  ) ) != CM, TT), Post, S) ~> A ~> waitingForChild
               ...</k>
          ...</thread>
          <omp-current-threads> TotalThreads:Int</omp-current-threads>
          requires Th ==Int ThId andBool Th ==Int 0 andBool TotalThreads =/=Int 0


     rule [other-thread-omp-parallel-for]:
          <thread>
          ...
               <thread-id> Parent:Int </thread-id>
               <thread-local> 
                    C:Bag 
                    <parent-thread> _ </parent-thread>
                    <child-threads> ... .Set => SetItem(Fresh)</child-threads>
               </thread-local>
               <k> 
                    blockOmpParallelFor(Th:Int, B:K, A:K, declareInternalVariable(X:CId, _, initValue(_, T:Type, Computation( te(Y:KItem := V:KItem, _)))), te((I:KItem < N:KItem) != CM:KItem, TT:Type), Post:K, S:K)
                    => blockOmpParallelFor(Th -Int 1, B:K, A:K, declareInternalVariable(X, T, initValue(X, T, Computation(te( Y := V, T)))), te((I < N) != CM, TT),  Post, S)
               ...
               </k>
          ...
          </thread>
          <next-thread-id> Fresh:Int => Fresh +Int 1 </next-thread-id>
          <omp-current-threads> TotalThreads:Int </omp-current-threads>
          (.Bag =>
          <thread>
          ...
               <thread-id> Fresh:Int </thread-id>
               <k>  
                   B ~> declareInternalVariable(X, T, initValue(X, T, Computation( te(Y := ( (N % tv(TotalThreads, TT)) + ( (N / tv( TotalThreads, TT)) * tv(TotalThreads -Int Th, TT) ) ), TT))) ) ~> For(te((I < ( (N % tv(TotalThreads, TT)) + ( (N / tv( TotalThreads, TT)) * tv(TotalThreads -Int Th +Int 1, TT) ) )) != CM, TT), Post, S) ~> A ~> joinChild
               </k>
               <duration> thread(Fresh:Int) </duration>
               <thread-local>
                    C
                    <parent-thread> Parent </parent-thread>
                    <child-threads> .Set </child-threads>
               </thread-local>
          ...
          </thread>)
          requires Th =/=Int 0 andBool TotalThreads =/=Int 0
          [large, ndthread]
//*/
     rule [other-thread-omp-parallel]:
          <thread>
          ...
               <thread-id> Parent:Int </thread-id>
               <thread-local> 
                    C:Bag 
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
          <omp-current-threads> TotalThreads:Int </omp-current-threads>
          (.Bag =>
          <thread>
          ...
               <thread-id> Fresh:Int </thread-id>
               <k>  
                   B ~> S ~> A ~> joinChild
               </k>
               <duration> thread(Fresh:Int) </duration>
               <thread-local>
                    C
                    <parent-thread> Parent </parent-thread>
                    <child-threads> .Set </child-threads>
               </thread-local>
          ...
          </thread>)
          requires Th =/=Int 0 andBool TotalThreads =/=Int 0
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

     rule <k> BeforeOmp(K:K)
               => K
          ...</k> 

     rule <k> AfterOmp(K:K)
               => K
          ...</k> 

     /*@ \fromStandard{\source[n1570]{\para{6.8.5.1}{1}}}{
     The evaluation of the controlling expression takes place before each
     execution of the loop body.
     }*/

     rule [while-mark]:
          <k>
               While(B:K, S:K) ~> K:K
               => loopMarked
                    ~> While(B, S)
                    ~> popLoop
          </k>
          <block-history> ListItem(Num:Int) ...</block-history>
          <loop-stack> .List => ListItem(kpair(Num, K)) ...</loop-stack>
          [structural]
     rule [while]:
          loopMarked ~> While(B:K, S:K)
          => IfThenElse(B, (S ~> loopMarked ~> While(B, S)), Nop)
          [structural]  // rule so that looping programs see repetition

     /*@ \fromStandard{\source[n1570]{\para{6.8.5.2}{1}}}{
     The evaluation of the controlling expression takes place after each
     execution of the loop body.
     }*/

     rule [do-while-mark]:
          <k>
               DoWhile(B:K, S:K) ~> K:K
               => loopMarked
                    ~> DoWhile(B, S)
                    ~> popLoop
          </k>
          <block-history> ListItem(Num:Int) ...</block-history>
          <loop-stack> .List => ListItem(kpair(Num, K)) ...</loop-stack>
          [structural]
     rule [do-while]:
          loopMarked ~> DoWhile(B:K, S:K)
          => S ~> IfThenElse(B, (loopMarked ~> DoWhile(B, S)), Nop)
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
          Continue ~> ((L:KLabel)(_) => .K)
          requires (L =/=KLabel 'loopMarked)
               andBool (L =/=KLabel 'popBlock)
               andBool (L =/=KLabel 'pushBlock)
               andBool (L =/=KLabel 'popLoop)
          [structural]
     rule [continue-through-pop]:
          Continue ~> popBlock
          => popBlock ~> Continue
          [structural]

     rule [continue-done-for]:
          (Continue => Computation(Post))
          ~> loopMarked
          ~> For(_, Post:K, _)
          [structural]
     rule [continue-done]:
          (Continue => .K) ~> loopMarked ~> L:KLabel(_)
          requires L =/=KLabel 'For
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
