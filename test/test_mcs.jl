using Mimi
using MimiDICE2016
using Test

@testset "MCS" begin

m = MimiDICE2016.get_model()
mcs = MimiDICE2016.get_mcs()
sim_inst = run(mcs, m, 1000)

end