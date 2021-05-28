
# Model and scenario choices
@enum model_choice DICE
@enum scenario_choice USG1=1 USG2=2 USG3=3 USG4=4 USG5=5
const scenarios = [USG1, USG2, USG3, USG4, USG5]    # for use in iterating
# const tsd_scenario_names = ["IMAGE", "MERGE Optimistic", "MESSAGE", "MiniCAM Base", "5th Scenario"]

# Default values for user facing functions
const _default_year = 2020                                  # default perturbation year for marginal damages and scc
const _default_discount = 0.03                              # 3% constant discounting
const _default_horizon = 2300                               # Same as H (the variable name used by the IWG in DICE)
const _default_discount_rates = [.025, .03, .05]            # used by MCS
const _default_perturbation_years = collect(2020:5:2070)    # years for which to calculate the SCC

# Roe and Baker climate sensitivity distribution file
# const RBdistribution_file = joinpath(@__DIR__, "../../data/IWG_inputs/DICE/2009 11 23 Calibrated R&B distribution.xls")
# const RB_cs_values = Vector{Float64}(readxl(RBdistribution_file, "Sheet1!A2:A1001")[:, 1])  # cs values
# const RB_cs_probs  = Vector{Float64}(readxl(RBdistribution_file, "Sheet1!B2:B1001")[:, 1])  # probabilities associated with those values

#------------------------------------------------------------------------------
# 1. DICE specific constants
#------------------------------------------------------------------------------

const iwg_dice_input_file = joinpath(@__DIR__, "../data/SCC_input_EMFscenarios.xls")

const dice_ts = 5                      # length of DICE timestep: 5 years
# const dice_years = 2005:dice_ts:2405   # time dimension of the IWG's DICE model

const dice_inflate = 113.625 / 87.421 # GDP inflator 2005 => 2020, accessed 5/28/2021, https://apps.bea.gov/iTable/iTable.cfm?reqid=19&step=3&isuri=1&select_all_years=0&nipa_table_list=13&series=a&first_year=2005&last_year=2020&scale=-99&categories=survey&thetable=

const dice_scenario_convert = Dict{scenario_choice, String}(    # convert from standard names to the DICE-specific names used in the input files
    USG1 => "IMAGE",
    USG2 => "MERGEoptimistic",
    USG3 => "MESSAGE",
    USG4 => "MiniCAMbase",
    USG5 => "5thScenario"
)

const dice_scenario_specific_params = [
    :l,
    :E,
    :forcoth,
    :al,
    :k0
]

function _dice_normalization_factor(gas::Symbol)
    if gas == :CO2
        return 1e3 * 12/44  # Convert from trillion$/GtC/yr to $/tCO2/yr
    elseif gas in [:CH4, :N2O]
        return 1e6  # Convert from trillion$/MtX/yr to $/tX/yr
    else
        error("Unknown gas :$gas.")
    end
end
