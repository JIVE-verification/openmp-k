require "../translation/syntax.k"

module OPENMP-TRANSLATION
     imports C-ABSTRACT-REWRITING
     imports OPENMP-SYNTAX

     rule [omp-pragma-marker]:
          Pragma(KItem) => OMPPragmaMarker(KItem)
          [structural, priority(10)]
endmodule
