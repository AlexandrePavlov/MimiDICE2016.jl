@defcomp welfare begin
    CEMUTOTPER      = Variable(index=[time])    #Period utility
    CUMCEMUTOTPER   = Variable(index=[time])    #Cumulative period utility
    PERIODU         = Variable(index=[time])    #One period utility function
    UTILITY         = Variable()                #Welfare Function
    RR              = Variable(index=[time])    #Social time preference factor

    CPC             = Parameter(index=[time])   #Per capita consumption (thousands 2010 USD per year)
    l               = Parameter(index=[time])   #Level of population and labor
    prtp            = Parameter()               #Time premium per year
    ndgr            = Parameter()               #Non-diversifiable global risk (percent per year) 
    elasmu          = Parameter()               #Elasticity of marginal utility of consumption
    scale1          = Parameter()               #Multiplicative scaling coefficient
    scale2          = Parameter()               #Additive scaling coefficient

    function run_timestep(p, v, d, t)
        # Define function for PERIODU
        v.PERIODU[t] = (p.CPC[t] ^ (1 - p.elasmu) - 1) / (1 - p.elasmu) - 1

        # Define function for social time preference factor
        if is_first(t)
            v.RR[t] = 1.
        else
            v.RR[t] = v.RR[t - 1] / (1 + p.prtp + p.ndgr) ^ 5
        end

        # Define function for CEMUTOTPER
        v.CEMUTOTPER[t] = v.PERIODU[t] * p.l[t] * v.RR[t]

        # Define function for CUMCEMUTOTPER
        v.CUMCEMUTOTPER[t] = v.CEMUTOTPER[t] + (!is_first(t) ? v.CUMCEMUTOTPER[t-1] : 0)

        # Define function for UTILITY
        if is_last(t)
            v.UTILITY = 5 * p.scale1 * v.CUMCEMUTOTPER[t] + p.scale2
        end
    end
end