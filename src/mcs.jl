# Uncertain parameters defined in "Projections and Uncertainties about Climate
# Change in an Era of Minimal Climate Policies" (Nordhaus, 2018) EViews file
# provided by the AEJ : https://www.aeaweb.org/articles?id=10.1257/pol.20170046

# List of default component_name => variable_name values to save during the Monte 
# Carlo simulation
_default_save = [
    :damages => :DAMAGES,
    :grosseconomy => :YGROSS,
    :emissions => :E,
    :co2cycle => :MU,
    :damages => :DAMFRAC
]

_default_simdef = @defsim begin
    t2xco2 = LogNormal(1.106, 0.2646)       # Equilibrium climate sensitivity
    ga0 = Normal(0.076, 0.056)              # Initial TFP
    gsigma1 = Normal(-0.0152, 0.0032)       # initial decline in sigma
    mueq = LogNormal(5.851, 0.2649)         # Carbon coefficient
    a2 = Normal(0.00227, 0.001135)          # Damage coefficient
end

"""
    get_mcs(; save::Vector{Pair{Symbol, Symbol}} = _default_save)

Returns a Mimi Simulation Definition with the default random variables for DICE2016R. 
List of saved output variables can be modified with the `save` keyword.
"""
function get_mcs(; save::Vector{Pair{Symbol, Symbol}} = _default_save)
    mcs = deepcopy(_default_simdef)

    for (comp, var) in save
        Mimi.addSave!(mcs, comp, var)
    end

    return mcs
end