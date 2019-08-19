@defcomp grosseconomy begin
	GA		= Variable(index=[time])	#Growth rate of productivity
	AL		= Variable(index=[time])	#Level of total factor productivity
    K       = Variable(index=[time])    #Capital stock (trillions 2010 US dollars)
    YGROSS  = Variable(index=[time])    #Gross world product GROSS of abatement and damages (trillions 2010 USD per year)

	a0		= Parameter()				#Initial level of total factor productivity
	ga0		= Parameter()				#Initial growth rate for TFP per 5 years
	dela	= Parameter()				#Decline rate of TFP per 5 years
    I       = Parameter(index=[time])   #Investment (trillions 2010 USD per year)
    l       = Parameter(index=[time])   #Level of population and labor
    dk      = Parameter()               #Depreciation rate on capital (per year)
    gama    = Parameter()               #Capital elasticity in production function
    k0      = Parameter()               #Initial capital value (trill 2010 USD)

    function run_timestep(p, v, d, t)
		#Define function for GA
		for tm = 1:100
			v.GA[tm] = p.ga0 * exp(-p.dela * 5 * (tm-1))
		end
		
		#Define function for AL
		if is_first(t)
			v.AL[t] = p.a0
		else
			v.AL[t] = v.AL[t-1]/(1 - v.GA[t-1])
		end
		
        #Define function for K
        if is_first(t)
            v.K[t] = p.k0
        else
            v.K[t] = (1 - p.dk)^5 * v.K[t-1] + 5 * p.I[t-1]
        end

        #Define function for YGROSS
        v.YGROSS[t] = (v.AL[t] * (p.l[t]/1000)^(1-p.gama)) * (v.K[t]^p.gama)
    end
end