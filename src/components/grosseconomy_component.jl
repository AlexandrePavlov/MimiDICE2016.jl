@defcomp grosseconomy begin
    K       = Variable(index=[time])    #Capital stock (trillions 2010 US dollars)
    YGROSS  = Variable(index=[time])    #Gross world product GROSS of abatement and damages (trillions 2010 USD per year)

    AL      = Parameter(index=[time])   #Level of total factor productivity
    I       = Parameter(index=[time])   #Investment (trillions 2010 USD per year)
    l       = Parameter(index=[time])   #Level of population and labor
    dk      = Parameter()               #Depreciation rate on capital (per year)
    gama    = Parameter()               #Capital elasticity in production function
    k0      = Parameter()               #Initial capital value (trill 2010 USD)

    function run_timestep(p, v, d, t)
		
        #Define function for K
        if is_first(t)
            v.K[t] = p.k0
        else
            v.K[t] = (1 - p.dk)^5 * v.K[t-1] + 5 * p.I[t-1]
        end

        #Define function for YGROSS
        v.YGROSS[t] = (p.AL[t] * (p.l[t]/1000)^(1-p.gama)) * (v.K[t]^p.gama)
    end
end