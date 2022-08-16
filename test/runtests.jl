using Test
import IntrospectionTools
import PrettyTables

@testset "IntrospectionTools - instruction counts" begin
    (; table_data, header) = IntrospectionTools.instruction_counts(sin, (Float64, ));
    PrettyTables.pretty_table(
           table_data;
           header,
           crop = :none,
           alignment = vcat(:l, repeat([:r], length(header[1]) - 1)),
       )
end

@testset "IntrospectionTools code stats" begin
    IntrospectionTools.code_stats(sin, (Float64, ))
    IntrospectionTools.code_stats(sin, (Float32, ))
    IntrospectionTools.@code_stats sin(2.0)
end

@testset "IntrospectionTools code summary" begin
    IntrospectionTools.code_summary(sin, (Float32, ))
end

@testset "@boundscheck_elided" begin
    include("test_boundscheck_common.jl")
    main(Foo(rand(5,5)))
    s = Float64[0]
    main_nested!(s, Foo(rand(1,1000)))

    # specifying check-bounds
    p = run(`$(Base.julia_cmd()) --check-bounds=no  --project=$(pkgdir(IntrospectionTools))/test test_boundscheck_elided.jl`)
    @test p.exitcode == 0
    p = run(`$(Base.julia_cmd()) --check-bounds=yes --project=$(pkgdir(IntrospectionTools))/test test_boundscheck_not_elided.jl`)
    @test p.exitcode == 0

    # running normally:
    pkgd = pkgdir(IntrospectionTools)
    cd(pkgd) do
        p = run(`$(joinpath(Sys.BINDIR, "julia")) --project=$pkgd $pkgd/test/test_boundscheck_elided.jl`)
        @test p.exitcode == 0
    end

end
