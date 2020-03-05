using Test

@testset "MimiDICE2016" begin

    include("test_validation.jl")
    include("test_api.jl")
    include("test_extremes.jl")
    include("test_mcs.jl")

end

nothing