@defcomp radiativeforcing begin
	FORCOTH	  = Variable(index=[time])	 #Exogenous forcing for other greenhouse gases
    FORC      = Variable(index=[time])   #Increase in radiative forcing (watts per m2 from 1900)

    MAT       = Parameter(index=[time])  #Carbon concentration increase in atmosphere (GtC from 1750)
    eqmat     = Parameter()              #Equilibrium concentration of CO2 in atmosphere (GTC)
    fco22x    = Parameter()              #Forcings of equilibrium CO2 doubling (Wm-2)
	fex0	  = Parameter()				 #2015 forcings of non-CO2 GHG (Wm-2)
	fex1	  = Parameter()				 #2100 forcings of non-CO2 GHG (Wm-2)

    function run_timestep(p, v, d, t)
		#Define function for FORCOTH
		for tm = 1:100
			if tm < 19
				v.FORCOTH[tm] = p.fex0 + (1/17) * (p.fex1 - p.fex0) * (tm - 1)
			else
				v.FORCOTH[tm] = p.fex0 + (p.fex1 - p.fex0)
			end
		end
		
        #Define function for FORC
        v.FORC[t] = p.fco22x * (log((p.MAT[t] / p.eqmat)) / log(2)) + v.FORCOTH[t]
    end
end