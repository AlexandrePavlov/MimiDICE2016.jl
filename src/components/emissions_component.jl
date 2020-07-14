@defcomp emissions begin
	SIG0	= Variable()				#Carbon intensity 2010-2015 (kgCO2 per output 2010 USD)
	GSIG	= Variable(index=[time])	#Change in sigma (cumulative improvement of energy efficiency)
	SIGMA	= Variable(index=[time])	#CO2-equivalent-emissions output ratio
    EIND    = Variable(index=[time])    #Industrial emissions (GtCO2 per year)
	ETREE	= Variable(index=[time])	#Emissions from deforestation
    E       = Variable(index=[time])    #Total CO2 emissions (GtCO2 per year)
	CUMETREE= Variable(index=[time])	#Cumulative from land
    CCA     = Variable(index=[time])    #Cumulative industrial emissions
	CCATOT	= Variable(index=[time])	#Cumulative total carbon emissions

	gsigma1 = Parameter()				#Initial growth of sigma (per year)
	dsig	= Parameter()				#Decline rate of decarbonization (per period)
	eland0	= Parameter()				#Carbon emissions from land 2015 (GtCO2 per year)
	deland	= Parameter()				#Decline rate of land emissions (per period)
	e0		= Parameter()				#Industrial emissions 2015 (GtCO2 per year)
    MIU     = Parameter(index=[time])   #Emission control rate GHGs
    YGROSS  = Parameter(index=[time])   #Gross world product GROSS of abatement and damages (trillions 2010 USD per year)
    cca0    = Parameter()               #Initial cumulative industrial emissions
	cumetree0=Parameter()				#Initial emissions from deforestation (see GAMS code)

    function run_timestep(p, v, d, t)
		#Define SIG0
			v.SIG0 = p.e0/(p.YGROSS[TimestepIndex(1)] * (1 - p.MIU[TimestepIndex(1)]))
			
		#Define function for GSIG
		if is_first(t)
			v.GSIG[t] = p.gsigma1
		else
			v.GSIG[t] = v.GSIG[t-1] * ((1 + p.dsig)^5)
		end
		
		#Define function for SIGMA
		if is_first(t)
			v.SIGMA[t] = v.SIG0
		else
			v.SIGMA[t] = v.SIGMA[t-1] * exp(v.GSIG[t-1] * 5)
		end
		
        #Define function for EIND
		v.EIND[t] = v.SIGMA[t] * p.YGROSS[t] * (1 - p.MIU[t])
    		
		#Define function for ETREE
		if is_first(t)
			v.ETREE[t] = p.eland0
		else
			v.ETREE[t] = v.ETREE[t - 1] * (1 - p.deland)
		end

        #Define function for E
        v.E[t] = v.EIND[t] + v.ETREE[t]
		
		#Define function for CUMETREE
		if is_first(t)
			v.CUMETREE[t] = p.cumetree0
		else
			v.CUMETREE[t] = v.CUMETREE[t-1] + v.ETREE[t-1]
		end
		
        #Define function for CCA
        if is_first(t)
            v.CCA[t] = p.cca0
        else
            v.CCA[t] = v.CCA[t-1] + v.EIND[t-1] * 5/3.666
        end
			
		#Define function for CCATOT
			v.CCATOT[t] = v.CCA[t] + v.CUMETREE[t]			

    end
end