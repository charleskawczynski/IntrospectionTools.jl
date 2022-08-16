using Test
import InteractiveUtils
using IntrospectionTools

struct Foo{A}
    data::A
end
Base.eltype(a::Foo) = eltype(a.data)
@inline function Base.getindex(a::Foo, i)
    @boundscheck (1 <= i <= length(a.data)) || throw(BoundsError(a.data, (i,)))
    a.data[i]
end
function main(f)
    s = zero(eltype(f))
    @inbounds for i in eachindex(f.data)
        s += f[i]
    end
    return s
end

struct Bar{A}
    data::A
end
@inline function Base.getindex(b::Bar, i) # no difference with Base.@propagate_inbounds
    @inbounds b.data[i] # @inbounds here decreases number of instructions
end
@inline function get_data(a::Foo, i) # no difference with Base.@propagate_inbounds
    @boundscheck (1 <= i <= length(a.data)) || throw(BoundsError(a.data, (i,)))
    dview = @inbounds view(a.data, :, i) # @inbounds here decreases number of instructions
    Bar(dview)
end

# A bunch of recursive `get_data` calls... All need `Base.@propagate_inbounds`
Base.@propagate_inbounds get_data(a::Foo, i1, i2, i3, i4, i5) = get_data(a, i1, i2, i3, i4)
Base.@propagate_inbounds get_data(a::Foo, i1, i2, i3, i4) = get_data(a, i1, i2, i3) # inbounds elided
# @inline get_data(a::Foo, i1, i2, i3, i4) = get_data(a, i1, i2, i3) # inbounds _NOT_ elided
Base.@propagate_inbounds get_data(a::Foo, i1, i2, i3) = get_data(a, i1, i2)
Base.@propagate_inbounds get_data(a::Foo, i1, i2) = get_data(a, i1)

function main_nested!(s, f)
    @inbounds for i in 1:size(f.data, 2) # @inbounds needed here
        s[1] += get_data(f, i, 2, 3, 4, 5)[1]
        # No difference compared to:
        #     data = get_data(f, i, 2, 3, 4, 5)
        #     idata = @inbounds data[1]
        #     @inbounds s[1] += idata
    end
    return nothing
end
