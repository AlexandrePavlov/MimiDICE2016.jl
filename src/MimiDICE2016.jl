module MimiDICE2016

using Mimi
using ExcelReaders

include("helpers.jl")
include("parameters.jl")

include("marginaldamage.jl")

include("components/grosseconomy_component.jl")
include("components/emissions_component.jl")
include("components/co2cycle_component.jl")
include("components/radiativeforcing_component.jl")
include("components/climatedynamics_component.jl")
include("components/damages_component.jl")
include("components/neteconomy_component.jl")
include("components/welfare_component.jl")

export constructdice, getdiceexcel, getdicegams

const model_years = 2015:5:2510

function constructdice(p)

    m = Model()
    set_dimension!(m, :time, model_years)

    add_comp!(m, grosseconomy, :grosseconomy)
    add_comp!(m, emissions, :emissions)
    add_comp!(m, co2cycle, :co2cycle)
    add_comp!(m, radiativeforcing, :radiativeforcing)
    add_comp!(m, climatedynamics, :climatedynamics)
    add_comp!(m, damages, :damages)
    add_comp!(m, neteconomy, :neteconomy)
    add_comp!(m, welfare, :welfare)

    # GROSS ECONOMY COMPONENT
    set_param!(m, :grosseconomy, :a0, p[:a0])
	set_param!(m, :grosseconomy, :ga0, p[:ga0])
	set_param!(m, :grosseconomy, :dela, p[:dela])
    set_param!(m, :grosseconomy, :l, p[:l])
    set_param!(m, :grosseconomy, :gama, p[:gama])
    set_param!(m, :grosseconomy, :dk, p[:dk])
    set_param!(m, :grosseconomy, :k0, p[:k0])

    # Note: offset=1 => dependence is on on prior timestep, i.e., not a cycle
    connect_param!(m, :grosseconomy, :I, :neteconomy, :I)

    # EMISSIONS COMPONENT
    set_param!(m, :emissions, :gsigma1, p[:gsigma1])
    set_param!(m, :emissions, :dsig, p[:dsig])
	set_param!(m, :emissions, :eland0, p[:eland0])
	set_param!(m, :emissions, :deland, p[:deland])
	set_param!(m, :emissions, :e0, p[:e0])
    set_param!(m, :emissions, :MIU, p[:MIU])
    set_param!(m, :emissions, :cca0, p[:cca0])
	set_param!(m, :emissions, :cumetree0, p[:cumetree0])
    connect_param!(m, :emissions, :YGROSS, :grosseconomy, :YGROSS)

    # CO2 CYCLE COMPONENT
    set_param!(m, :co2cycle, :mat0, p[:mat0])
    set_param!(m, :co2cycle, :mu0, p[:mu0])
    set_param!(m, :co2cycle, :ml0, p[:ml0])
    set_param!(m, :co2cycle, :b12, p[:b12])
    set_param!(m, :co2cycle, :b23, p[:b23])
	set_param!(m, :co2cycle, :mateq, p[:mateq])
	set_param!(m, :co2cycle, :mleq, p[:mleq])
	set_param!(m, :co2cycle, :mueq, p[:mueq])
    connect_param!(m, :co2cycle, :E, :emissions, :E)

    # RADIATIVE FORCING COMPONENT
    set_param!(m, :radiativeforcing, :fex0, p[:fex0])
    set_param!(m, :radiativeforcing, :fex1, p[:fex1])
    set_param!(m, :radiativeforcing, :fco22x, p[:fco22x])
    set_param!(m, :radiativeforcing, :eqmat, p[:eqmat])
    connect_param!(m, :radiativeforcing, :MAT, :co2cycle, :MAT)

    # CLIMATE DYNAMICS COMPONENT
    set_param!(m, :climatedynamics, :fco22x, p[:fco22x])
    set_param!(m, :climatedynamics, :t2xco2, p[:t2xco2])
    set_param!(m, :climatedynamics, :tatm0, p[:tatm0])
    set_param!(m, :climatedynamics, :tocean0, p[:tocean0])
    set_param!(m, :climatedynamics, :c1, p[:c1])
    set_param!(m, :climatedynamics, :c3, p[:c3])
    set_param!(m, :climatedynamics, :c4, p[:c4])
    connect_param!(m, :climatedynamics, :FORC, :radiativeforcing, :FORC)

    # DAMAGES COMPONENT
    set_param!(m, :damages, :a1, p[:a1])
    set_param!(m, :damages, :a2, p[:a2])
    set_param!(m, :damages, :a3, p[:a3])
    connect_param!(m, :damages, :TATM, :climatedynamics, :TATM)
    connect_param!(m, :damages, :YGROSS, :grosseconomy, :YGROSS)

    # NET ECONOMY COMPONENT
    set_param!(m, :neteconomy, :MIU, p[:MIU])
    set_param!(m, :neteconomy, :expcost2, p[:expcost2])
    set_param!(m, :neteconomy, :pback, p[:pback])
	set_param!(m, :neteconomy, :gback, p[:gback])
    set_param!(m, :neteconomy, :S, p[:S])
    set_param!(m, :neteconomy, :l, p[:l])
    connect_param!(m, :neteconomy, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :neteconomy, :DAMAGES, :damages, :DAMAGES)
	connect_param!(m, :neteconomy, :SIGMA, :emissions, :SIGMA)

    # WELFARE COMPONENT
    set_param!(m, :welfare, :l, p[:l])
    set_param!(m, :welfare, :elasmu, p[:elasmu])
    set_param!(m, :welfare, :rr, p[:rr])
    set_param!(m, :welfare, :scale1, p[:scale1])
    set_param!(m, :welfare, :scale2, p[:scale2])
    connect_param!(m, :welfare, :CPC, :neteconomy, :CPC)

    return m

end

function getdiceexcel(;datafile = joinpath(dirname(@__FILE__), "..", "data", "DICE2016R-090916ap-v2.xlsm"))
    params = getdice2016excelparameters(datafile)

    m = constructdice(params)

    return m
end

function getdicegams(;datafile = joinpath(dirname(@__FILE__), "..", "data", "DICE2016_IAMF_Parameters.xlsx"))
    params = getdice2016gamsparameters(datafile)

    m = constructdice(params)

    return m
end

# get_model function for standard Mimi API: use the Excel version
get_model = getdiceexcel

end # module