# Run tests on SCC and other standard API

using Mimi
using MimiDICE2016
using Test

@testset "Standard API" begin

m = MimiDICE2016.get_model()
run(m)

# Test the errors
@test_throws ErrorException MimiDICE2016.compute_scc()  # test that it errors if you don't specify a year
@test_throws ErrorException MimiDICE2016.compute_scc(year=2021)  # test that it errors if the year isn't in the time index
@test_throws ErrorException MimiDICE2016.compute_scc(last_year=2299)  # test that it errors if the last_year isn't in the time index
@test_throws ErrorException MimiDICE2016.compute_scc(year=2105, last_year=2100)  # test that it errors if the year is after last_year

# Test the SCC 
scc1 = MimiDICE2016.compute_scc(year=2020)
@test scc1 isa Float64

# Test that it's smaller with a shorter horizon
scc2 = MimiDICE2016.compute_scc(year=2020, last_year=2200)
@test scc2 < scc1

# Test that it's smaller with a larger prtp
scc3 = MimiDICE2016.compute_scc(year=2020, last_year=2200, prtp=0.02)
@test scc3 < scc2

# Test with a modified model 
m = MimiDICE2016.get_model()
update_param!(m, :t2xco2, 5)    
scc4 = MimiDICE2016.compute_scc(m, year=2020)
@test scc4 > scc1   # Test that a higher value of climate sensitivty makes the SCC bigger

# Test compute_scc_mm
result = MimiDICE2016.compute_scc_mm(year=2030)
@test result.scc isa Float64
@test result.mm isa Mimi.MarginalModel
marginal_temp = result.mm[:climatedynamics, :TATM]
@test all(marginal_temp[1:findfirst(isequal(2030), MimiDICE2016.model_years)] .== 0.)
@test all(marginal_temp[findfirst(isequal(2035), MimiDICE2016.model_years):end] .!= 0.)

end