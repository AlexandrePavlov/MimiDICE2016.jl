# Run tests on the whole model

# using CSVFiles
using ExcelReaders
using Mimi
using MimiDICE2016
using Test

import MimiDICE2016: getparams

@testset "validation" begin

m = MimiDICE2016.get_model();
run(m)

f = openxl(joinpath(@__DIR__, "../data/DICE2016R-090916ap-v2.xlsm"))

#Test Precision
Precision = 1.0e-10

#Time Periods
T=100

#TATM Test (temperature increase)
True_TATM = getparams(f, "B99:CW99", :all, "Base", T);
@test maximum(abs, m[:climatedynamics, :TATM] .- True_TATM) ≈ 0. atol = Precision

#MAT Test (carbon concentration atmosphere)
True_MAT = getparams(f, "B87:CW87", :all, "Base", T);
@test maximum(abs, m[:co2cycle, :MAT] .- True_MAT) ≈ 0. atol = Precision

#DAMFRAC Test (damages fraction)
True_DAMFRAC = getparams(f, "B105:CW105", :all, "Base", T);
@test maximum(abs, m[:damages, :DAMFRAC] .- True_DAMFRAC) ≈ 0. atol = Precision

#DAMAGES Test (damages $)
True_DAMAGES = getparams(f, "B106:CW106", :all, "Base", T);
@test maximum(abs, m[:damages, :DAMAGES] .- True_DAMAGES) ≈ 0. atol = Precision

#E Test (emissions)
True_E = getparams(f, "B112:CW112", :all, "Base", T);
@test maximum(abs, m[:emissions, :E] .- True_E) ≈ 0. atol = Precision

#YGROSS Test (gross output)
True_YGROSS = getparams(f, "B104:CW104", :all, "Base", T);
@test maximum(abs, m[:grosseconomy, :YGROSS] .- True_YGROSS) ≈ 0. atol = Precision

#AL test (total factor productivity)
True_AL = getparams(f, "B21:CW21", :all, "Base", T);
@test maximum(abs, m[:totalfactorproductivity, :AL] .- True_AL) ≈ 0. atol = Precision

#CPC Test (per capita consumption)
True_CPC = getparams(f, "B126:CW126", :all, "Base", T);
@test maximum(abs, m[:neteconomy, :CPC] .- True_CPC) ≈ 0. atol = Precision

#FORCOTH Test (exogenous forcing)
True_FORCOTH = getparams(f, "B73:CW73", :all, "Base", T);
@test maximum(abs, m[:radiativeforcing, :FORCOTH] .- True_FORCOTH) ≈ 0. atol = Precision

#FORC Test (radiative forcing)
True_FORC = getparams(f, "B100:CW100", :all, "Base", T);
@test maximum(abs, m[:radiativeforcing, :FORC] .- True_FORC) ≈ 0. atol = Precision

#Utility Test
True_UTILITY = getparams(f, "B129:B129", :single, "Base", T);
@test maximum(abs, m[:welfare, :UTILITY] .- True_UTILITY) ≈ 0. atol = Precision

end