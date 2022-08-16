module IntrospectionTools

export @code_summary
import InteractiveUtils

function get_code_native_str(f, types...)
    io = IOBuffer()
    InteractiveUtils.code_native(io, f, types...; debuginfo=:none);
    return String(take!(io));
end

function get_code_llvm_str(f, types...)
    io = IOBuffer()
    InteractiveUtils.code_llvm(io, f, types...; debuginfo=:none);
    return String(take!(io));
end

const funcs_to_make = (
    :code_stats,
    :boundscheck_elided,
    :instruction_counts,
    :code_summary,
)
include("gen_call_with_extracted_types.jl") # From Julia Base
include("instruction_list.jl")

struct CodeStats{T}
    s_llvm::String
    s_native::String
    jl_calls::Dict
    n_inbounds::Int
    n_instructions::Int
    instr_counts::T
end

function code_stats(f, types...)
    # TODO: get costs of instructions?
    s_native = get_code_native_str(f, types...)
    s_llvm = get_code_llvm_str(f, types...)

    # instr_costs = Dict(map(k->Pair(k, nothing), fieldnames(InstructionList)))
    instr_count_pairs = map(fieldnames(InstructionList)) do instr
        Pair(instr, count("\t$instr", s_native))
    end
    n_inbounds = count(" inbounds ", s_llvm)
    instr_counts = InstructionList{Int}(;instr_count_pairs...)
    pns = propertynames(instr_counts)
    instr_count_values = map(pn-> getproperty(instr_counts, pn), pns)
    n_instructions = sum(instr_count_values)
    jl_calls = Dict()
    for flag in boundscheck_flags
        jl_calls[flag] = count(flag, s_llvm)
    end
    return CodeStats(s_llvm, s_native, jl_calls, n_inbounds, n_instructions, instr_counts)
end

#####
##### Instruction counts
#####

instruction_counts(f, types...) = instruction_counts(code_stats(f, types...))

function instruction_counts(cs::CodeStats)
    pns = propertynames(cs.instr_counts)
    instr_counts = map(pn-> getproperty(cs.instr_counts, pn), pns)
    table_data = hcat(string.(collect(pns)), collect(instr_counts))
    header = (["Instruction name", "Count",], ["", "",])
    return (; table_data, header)
end

#####
##### Code sumamry
#####

code_summary(f, types...) = code_summary(code_stats(f, types...))
function code_summary(cs::CodeStats)
    n_native = length(cs.s_native)
    n_llvm = length(cs.s_llvm)
    println("------------------------------------ Code summary")
    @info "`n_instructions` = $(cs.n_instructions)"
    @info "`n_inbounds` = $(cs.n_inbounds)"
    @info "`n_jl_calls` = $(sum(values(cs.jl_calls)))"
    @info "length(code_native): $n_native"
    @info "length(code_llvm): $n_llvm"
    @info "length(code_llvm)/length(code_native): $(n_llvm/n_native)"
    println("------------------------------------")
    return nothing
end

#####
##### Code lengths
#####

code_lengths(f, types...) = code_lengths(code_stats(f, types...))
function code_lengths(cs::CodeStats)
    n_native = length(cs.s_native)
    n_llvm = length(cs.s_llvm)
    @info "length(code_native): $n_native"
    @info "length(code_llvm): $n_llvm"
    @info "length(code_llvm)/length(code_native): $(n_llvm/n_native)"
    return (;native = n_native, llvm = n_llvm)
end

#####
##### Test elided bounds check
#####

# This is a hack, but it's working for the simple case
const boundscheck_flags = [
    # Needed for julia 1.8
    "@ijl_gc_pool_alloc(",
    "@ijl_get_binding_or_error(",
    "@ijl_bounds_error_ints(",
    "@ijl_apply_generic(",
    "@ijl_bounds_error(",
    "@ijl_type_error(",
    "@ijl_box_int64(",
    "@ijl_undefined_var_error(",
    "@ijl_throw(",
    # Needed for julia 1.7
    "@jl_gc_pool_alloc(",
    "@jl_get_binding_or_error(",
    "@jl_bounds_error_ints(",
    "@jl_apply_generic(",
    "@jl_bounds_error(",
    "@jl_type_error(",
    "@jl_box_int64(",
    "@jl_undefined_var_error(",
    "@jl_throw(",
]

boundscheck_elided(f, types...) = boundscheck_elided(code_stats(f, types...))
function boundscheck_elided(cs::CodeStats)
    code_summary(cs)
    return all(values(cs.jl_calls) .== 0)
end

end # module
