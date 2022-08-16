# IntrospectionTools.jl

Experimental introspection tools in Julia. See the test directory for examples.

> :warning: **This package was built using heuristics based on a very specific example of interest, and requires at least Julia 1.7 to work properly. Use with extreme caution.**


## Motivation

Analyzing inference, and effects from using things like `@inline`, can be difficult in larger code bases where practical applications result in lots of generated code. This package was developed to quickly assist in answering the question: does change `X` in some code impact LLVM or native code _at all_?

## Example

Here is a simple example:
```julia
using IntrospectionTools
@code_summary sin(1)
```

Which outputs:
```julia
julia> using IntrospectionTools
[ Info: Precompiling IntrospectionTools [d8c2de52-12b9-4615-9650-95773b5c37e8]

julia> @code_summary sin(1)
------------------------------------ Code summary
[ Info: `n_instructions` = 5
[ Info: `n_inbounds` = 0
[ Info: `n_jl_calls` = 0
[ Info: length(code_native): 515
[ Info: length(code_llvm): 146
[ Info: length(code_llvm)/length(code_native): 0.283495145631068
------------------------------------
```

## Other features

IntrospectionTools.jl can also print out things like instruction counts for function calls:

```julia
julia> import PrettyTables

julia> import IntrospectionTools
[ Info: Precompiling IntrospectionTools [d8c2de52-12b9-4615-9650-95773b5c37e8]

julia> (; table_data, header) = IntrospectionTools.instruction_counts(sin, (Float64, ));

julia> PrettyTables.pretty_table(
           table_data;
           header,
           crop = :none,
           alignment = vcat(:l, repeat([:r], length(header[1]) - 1)),
       )
┌──────────────────┬───────┐
│ Instruction name │ Count │
│                  │       │
├──────────────────┼───────┤
│ pushq            │     0 │
│ subq             │     1 │
│ movq             │     2 │
│ vmovsd           │    25 │
│ movabsq          │    88 │
│ leaq             │     0 │
│ callq            │     2 │
│ vmovups          │     0 │
│ addq             │     6 │
│ popq             │     0 │
│ vzeroupper       │     0 │
│ retq             │     6 │
│ nopw             │     0 │
│ shrq             │     9 │
│ andl             │    11 │
│ cmpl             │    17 │
│ vroundsd         │     4 │
│ shrl             │     2 │
│ movl             │     7 │
│ cmpq             │     1 │
│ vandpd           │     1 │
│ vucomisd         │     8 │
│ vsubsd           │    67 │
│ vxorpd           │     6 │
│ vmovq            │     9 │
│ vmulsd           │    59 │
│ vfmadd213sd      │    17 │
│ vaddsd           │    37 │
│ vfmadd231sd      │     4 │
│ subl             │     8 │
│ vfmsub231sd      │     8 │
│ vmovapd          │     4 │
│ vcvttsd2si       │     4 │
│ testq            │     1 │
└──────────────────┴───────┘
```
