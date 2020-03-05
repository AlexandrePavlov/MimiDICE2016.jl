using Mimi
using MimiDICE2016
using Test

@testset "Extreme scenarios" begin

#----------------------------------------------------------------------------------------
# Test a model where DAMFRAC exceeds 100% 
#----------------------------------------------------------------------------------------

m1 = MimiDICE2016.get_model()
update_param!(m1, :t2xco2, 10)       # high climate sensitivity
update_param!(m1, :MIU, zeros(100))  # no abatement
@test_throws DomainError run(m1)  # In the default version, DAMFRAC exceeds 100%, consumption is negative, and the welfare component fails

# If we use the added `cap_damages` flag, YNET well have a floor at zero, and welfare component no longer errors
update_param!(m1, :cap_damages, true)
run(m1)
@test all(m1[:neteconomy, :YNET] .>= 0)


#----------------------------------------------------------------------------------------
# Test a model where ABATECOST exceeds YGROSS
#----------------------------------------------------------------------------------------

m2 = MimiDICE2016.get_model()
update_param!(m2, :MIU, ones(100))   # full abatement
update_param!(m2, :pback, 1_000_000) # very expensive backstop
@test_throws DomainError run(m2)

# If we use the added `cap_abatecost` flag, Y well have a floor at zero, and welfare component no longer errors
update_param!(m2, :cap_abatecost, true)
run(m2)
@test all(m1[:neteconomy, :Y] .>= 0)

end