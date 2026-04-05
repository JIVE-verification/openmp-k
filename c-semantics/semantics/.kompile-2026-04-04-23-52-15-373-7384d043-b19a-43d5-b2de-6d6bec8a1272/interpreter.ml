let () = Plugin.load Sys.argv.(1)
open Prelude
open Constants
open Constants.K
open Run
let () = Sys.catch_break true
let () = Gc.set { (Gc.get()) with Gc.minor_heap_size = 33554432 }let try_match (c: k) (config: k) (guard: int) : k Subst.t = match c with 
(*{| rule `<generatedTop>`(_1,_2,`<result-value>`(_0),_3,_4) requires isInt(_0) ensures #token("true","Bool") []|}*)
| (KApply5(Lbl'_LT_'generatedTop'_GT_',(var_1_52026),(var_2_52027),(KApply1(Lbl'_LT_'result'Hyph'value'_GT_',((Int _ as var_0_52028) :: [])) :: []),(var_3_52029),(var_4_52030)) :: []) when true && (true) -> (Subst.add "_2" var_2_52027 (Subst.add "_3" var_3_52029 (Subst.add "_1" var_1_52026 (Subst.add "_0" [var_0_52028] (Subst.add "_4" var_4_52030 Subst.empty)))))
| _ -> raise(Stuck c)
let input, depth, out = Makeconfig.parse ()
let res, _ = run_no_thread_opt(input) (depth)
let () = output_string out (print_k_binary(res))
let () = try let subst = try_match res res (-1) in
let code = get_exit_code subst in
exit code
with Stuck(res) -> output_string out (print_k_binary res); exit 112
