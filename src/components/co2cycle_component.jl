@defcomp co2cycle begin
    b11     = Variable()                #Carbon cycle transition matrix atmosphere to atmosphere
	b21		= Variable()				#Carbon cycle transition matrix biosphere/shallow oceans to atmosphere
    b22     = Variable()                #Carbon cycle transition matrix shallow ocean to shallow oceans
    b32     = Variable()                #Carbon cycle transition matrix deep ocean to shallow ocean
    b33     = Variable()                #Carbon cycle transition matrix deep ocean to deep oceans
    MAT     = Variable(index=[time])    #Carbon concentration increase in atmosphere (GtC from 1750)
    ML      = Variable(index=[time])    #Carbon concentration increase in lower oceans (GtC from 1750)
    MU      = Variable(index=[time])    #Carbon concentration increase in shallow oceans (GtC from 1750)

    b12     = Parameter()               #Carbon cycle transition matrix atmosphere to shallow ocean
    b23     = Parameter()               #Carbon cycle transition matrix shallow to deep ocean
	mateq	= Parameter()				#Equilibrium concentration atmosphere (GtC)
	mueq 	= Parameter()				#Equilibrium concentration in upper strata (GtC)
	mleq	= Parameter()				#Equilibrium concentration in lower strata (GtC)
    E       = Parameter(index=[time])   #Total CO2 emissions (GtCO2 per year)
    mat0    = Parameter()               #Initial Concentration in atmosphere 2010 (GtC)
    ml0     = Parameter()               #Initial Concentration in lower strata 2010 (GtC)
    mu0     = Parameter()               #Initial Concentration in upper strata 2010 (GtC)

    function run_timestep(p, v, d, t)
		#Define function for b11
		v.b11 = 1 - p.b12
		
		#Define function for b21
		v.b21 = p.b12 * p.mateq/p.mueq
		
		#Define function for b22
		v.b22 = 1 - v.b21 - p.b23
		
		#Define function for b32
		v.b32 = p.b23 * p.mueq/p.mleq
		
		#Define function for b33
		v.b33 = 1 - v.b32
		
        #Define function for MAT
        if is_first(t)
            v.MAT[t] = p.mat0
        else
            v.MAT[t] = v.MAT[t-1] * v.b11 + v.MU[t-1] * v.b21 + (p.E[t-1]*(5/3.666))
        end

        #Define function for MU
        if is_first(t)
            v.MU[t] = p.mu0
        else
            v.MU[t] = v.MAT[t-1] * p.b12 + v.MU[t-1] * v.b22 + v.ML[t-1] * v.b32
        end

        #Define function for ML
        if is_first(t)
            v.ML[t] = p.ml0
        else
            v.ML[t] = v.ML[t-1] * v.b33 + v.MU[t-1] * p.b23
        end
    end
end