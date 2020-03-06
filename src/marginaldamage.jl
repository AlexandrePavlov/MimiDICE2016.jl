"""
    compute_scc(m::Model=get_model(); 
        year::Union{Int, Nothing} = nothing, 
        last_year::Int = model_years[end], 
        prtp::Float64 = 0.015, 
        eta::Float64=1.45, 
        n::Union{Int, Nothing}=nothing, 
        seed::Union{Int, Nothing}=nothing, 
        trials_output_filename::Union{String, Nothing}=nothing)

Computes the social cost of CO2 for an emissions pulse in `year` for the provided MimiDICE2016 model. 
If no model is provided, the default model from MimiDICE2016.get_model() is used.

The discounting scheme can be specified by the `eta` and `prtp` parameters. If no values are provided, default
values of 1.45 and 0.015 will be used.

By default, `n = nothing`, and a single value for the "best guess" social cost of CO2 is returned. If a positive 
value for keyword `n` is specified, then a Monte Carlo simulation with sample size `n` will run, sampling from 
all of DICE2016's random variables, and a vector of `n` social cost values will be returned.
Optionally providing a CSV file path to `trials_output_filename` will save all of the sampled trial data as a CSV file.
Optionally providing a `seed` value will set the random seed before running the simulation, allowing the 
results to be replicated.
"""
function compute_scc(m::Model=get_model(); 
    year::Union{Int, Nothing} = nothing, 
    last_year::Int = model_years[end], 
    prtp::Float64 = 0.015, 
    eta::Float64=1.45, 
    n::Union{Int, Nothing}=nothing, 
    seed::Union{Int, Nothing}=nothing, 
    trials_output_filename::Union{String, Nothing}=nothing)

    year === nothing ? error("Must specify an emission year. Try `compute_scc(m, year=2020)`.") : nothing
    !(last_year in model_years) ? error("Invalid value of $last_year for last_year. last_year must be within the model's time index $model_years.") : nothing
    !(year in model_years[1]:5:last_year) ? error("Cannot compute the scc for year $year, year must be within the model's time index $(model_years[1]):5:$last_year.") : nothing

    ntimesteps = findfirst(isequal(last_year), model_years)     # Will run through the timestep of the specified last_year 

    mm = get_marginal_model(m; year = year)
    run(mm, ntimesteps=ntimesteps)

    return _compute_scc(mm, year=year, last_year=last_year, prtp=prtp, eta=eta, n=n, seed=seed, trials_output_filename=trials_output_filename)
end

"""
    compute_scc_mm(m::Model=get_model(); 
        year::Union{Int, Nothing} = nothing, 
        last_year::Int = model_years[end], 
        prtp::Float64 = 0.015, 
        eta::Float64=1.45, 
        n::Union{Int, Nothing}=nothing, 
        seed::Union{Int, Nothing}=nothing, 
        trials_output_filename::Union{String, Nothing}=nothing)

Returns a NamedTuple (scc=scc, mm=mm) of the social cost of carbon and the MarginalModel used to compute it.
Computes the social cost of CO2 for an emissions pulse in `year` for the provided MimiDICE2016 model. 
If no model is provided, the default model from MimiDICE2016.get_model() is used.

The discounting scheme can be specified by the `eta` and `prtp` parameters. If no values are provided, default
values of 1.45 and 0.015 will be used.

By default, `n = nothing`, and a single value for the "best guess" social cost of CO2 is returned. If a positive 
value for keyword `n` is specified, then a Monte Carlo simulation with sample size `n` will run, sampling from 
all of DICE2016's random variables, and a vector of `n` social cost values will be returned.
Optionally providing a CSV file path to `trials_output_filename` will save all of the sampled trial data as a CSV file.
Optionally providing a `seed` value will set the random seed before running the simulation, allowing the 
results to be replicated.
"""
function compute_scc_mm(m::Model=get_model(); 
    year::Union{Int, Nothing} = nothing, 
    last_year::Int = model_years[end], 
    prtp::Float64 = 0.015, 
    eta::Float64=1.45, 
    n::Union{Int, Nothing}=nothing, 
    seed::Union{Int, Nothing}=nothing, 
    trials_output_filename::Union{String, Nothing}=nothing)

    year === nothing ? error("Must specify an emission year. Try `compute_scc_mm(m, year=2020)`.") : nothing
    !(last_year in model_years) ? error("Invalid value of $last_year for last_year. last_year must be within the model's time index $model_years.") : nothing
    !(year in model_years[1]:5:last_year) ? error("Cannot compute the scc for year $year, year must be within the model's time index $(model_years[1]):5:$last_year.") : nothing

    ntimesteps = findfirst(isequal(last_year), model_years)     # Will run through the timestep of the specified last_year 

    mm = get_marginal_model(m; year = year)
    run(mm, ntimesteps=ntimesteps)
    scc = _compute_scc(mm; year=year, last_year=last_year, prtp=prtp, eta=eta, n=n, seed=seed, trials_output_filename=trials_output_filename)
    
    return (scc = scc, mm = mm)
end

# helper function for computing SCC from a MarginalModel that has already been run, not to be exported or advertised to users
function _compute_scc(mm::MarginalModel; year::Int, last_year::Int, prtp::Float64, eta::Float64, n::Union{Int, Nothing}=nothing, seed::Union{Int, Nothing}=nothing, trials_output_filename::Union{String, Nothing}=nothing)
    
    ntimesteps = findfirst(isequal(last_year), model_years)     # Will run through the timestep of the specified last_year 

    if n === nothing

        marginal_damages = -1 * mm[:neteconomy, :C][1:ntimesteps] * 1e12     # Go from trillion$ to $; multiply by -1 so that damages are positive; pulse was in CO2 so we don't need to multiply by 12/44

        cpc = mm.base[:neteconomy, :CPC]

        year_index = findfirst(isequal(year), model_years)

        df = [zeros(year_index-1)..., ((cpc[year_index]/cpc[i])^eta * 1/(1+prtp)^(t-year) for (i,t) in enumerate(model_years) if year<=t<=last_year)...]
        scc = sum(df .* marginal_damages * 5)  # currently implemented as a 5year step function; so each timestep of discounted marginal damages is multiplied by 5
        
    elseif n < 1
        error("Invalid n = $n. Number of trials must be a positive integer.")
    else
        # Run a Monte Carlo simulation
        simdef = get_mcs()
        payload = (Vector{Float64}(undef, n), year, last_year, eta, prtp)
        Mimi.set_payload!(simdef, payload)
        seed !== nothing ? Random.seed!(seed) : nothing
        update_param!(mm.base, :cap_damages, true)
        update_param!(mm.base, :cap_abatecost, true)
        update_param!(mm.marginal, :cap_damages, true)
        update_param!(mm.marginal, :cap_abatecost, true)
        si = run(simdef, mm, n, ntimesteps = ntimesteps, post_trial_func = _dice_scc_post_trial, trials_output_filename = trials_output_filename)
        scc = Mimi.payload(si)[1]
    end
    
    return scc
end

# Post trial function used for computing SCC during Monte Carlo simulation
function _dice_scc_post_trial(sim::SimulationInstance, trialnum::Int, ntimesteps::Int, tup::Union{Tuple, Nothing})
    mm = sim.models[1]  # get the already-run MarginalModel
    (scc_results, year, last_year, eta, prtp) = Mimi.payload(sim)  # unpack the payload information
    scc = _compute_scc(mm, year = year, last_year = last_year, eta = eta, prtp = prtp)
    scc_results[trialnum] = scc
end

"""
get_marginal_model(m::Model = get_model(); year::Int = nothing)

Creates a Mimi MarginalModel where the provided m is the base model, and the marginal model has additional emissions of CO2 in year `year`.
If no Model m is provided, the default model from MimiDICE2016.get_model() is used as the base model.
"""
function get_marginal_model(m::Model=get_model(); year::Union{Int, Nothing} = nothing)
    year === nothing ? error("Must specify an emission year. Try `get_marginal_model(m, year=2015)`.") : nothing
    !(year in model_years) ? error("Cannot add marginal emissions in $year, year must be within the model's time index $(model_years[1]):10:$last_year.") : nothing

    mm = create_marginal_model(m, 5 * 1e9)    # 1 GtCO2 per year for 5 years, so 5 * 10^9
    add_marginal_emissions!(mm.marginal, year)

    return mm
end

"""
Adds a marginal emission component to year m which adds 1Gt of additional CO2 emissions per year for ten years starting in the specified `year`.
"""
function add_marginal_emissions!(m::Model, year::Int) 
    add_comp!(m, Mimi.adder, :marginalemission, before=:co2cycle)

    time = Mimi.dimension(m, :time)
    addem = zeros(length(time))
    addem[time[year]] = 1.0     # 1 GtCO2 per year for ten years

    set_param!(m, :marginalemission, :add, addem)
    connect_param!(m, :marginalemission, :input, :emissions, :E)
    connect_param!(m, :co2cycle, :E, :marginalemission, :output)
end



# Old available marginal model function 
function getmarginal_dice_models(;emissionyear=2010)

    DICE = constructdice()
    run(DICE)
    
    mm = MarginalModel(DICE)
    m1 = mm.base
    m2 = mm.marginal

    add_comp!(m2, adder, :marginalemission, before=:co2cycle)

    time = dimension(m1, :time)
    addem = zeros(length(time))
    addem[time[emissionyear]] = 1.0

    set_param!(m2, :marginalemission, :add, addem)
    connect_param!(m2, :marginalemission, :input, :emissions, :E)
    connect_param!(m2, :co2cycle, :E, :marginalemission, :output)

    run(m1)
    run(m2)

    return m1, m2
end