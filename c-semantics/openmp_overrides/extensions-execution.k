require "c-extensions-common.k"
require "cpp-extensions-common.k"
require "c/language/openmp/openmp_configuration.k"
require "c/language/openmp/openmp_semantics.k"
require "c/language/openmp/openmp_runtime.k"
require "c/language/openmp/openmp_builtins.k"

module C-CONFIGURATION-EXTENSIONS
     imports OPENMP-CONFIGURATION
endmodule

module EXECUTION-EXTENSIONS
     imports C-COMMON-EXTENSIONS
     imports CPP-COMMON-EXTENSIONS
     imports OPENMP-SEMANTICS
     imports OPENMP-RUNTIME
     imports OPENMP-BUILTINS
endmodule
