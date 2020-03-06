using Mimi
using MimiDICE2016
using Test

@testset "MCS" begin

m = MimiDICE2016.get_model()
mcs = MimiDICE2016.get_mcs()
sim_inst = run(mcs, m, 1000)

# test Monte Carlo SCC calculation
scc_vector = MimiDICE2016.compute_scc(year=2020, n=100)
@test sum(isnan.(scc_vector)) == 0

# Test setting the seed
sccs1 = MimiDICE2016.compute_scc(year=2040, n=50, seed=350)
sccs2 = MimiDICE2016.compute_scc(year=2040, n=50, seed=350)
@test sccs1 == sccs2

end