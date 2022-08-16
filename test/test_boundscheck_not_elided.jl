# julia --check-bounds=no  --project test/test_boundscheck_not_elided.jl # should fail
# julia --check-bounds=yes --project test/test_boundscheck_not_elided.jl # should pass
# julia --project test/test_boundscheck_elided.jl # ?

include("test_boundscheck_common.jl")
@testset "Test inbounds not elided" begin
    @info "************************************* boundscheck NOT elided"
    main(Foo(rand(5,5)))
    bce = IntrospectionTools.@boundscheck_elided main(Foo(rand(5,5)))
    @test !bce
    s = Float64[0]
    f = Foo(rand(1,1000))
    main_nested!(s, f)
    bce = IntrospectionTools.@boundscheck_elided main_nested!(s, f)
    @test !bce
    @info "*************************************"
end
