@defcomp damages begin
    DAMAGES = Variable(index=[time])    #Damages (trillions 2010 USD per year)
    DAMFRAC = Variable(index=[time])    #Damages (fraction of gross output)

    TATM    = Parameter(index=[time])   #Increase temperature of atmosphere (degrees C from 1900)
    YGROSS  = Parameter(index=[time])   #Gross world product GROSS of abatement and damages (trillions 2010 USD per year)
    a1      = Parameter()               #Damage coefficient
    a2      = Parameter()               #Damage quadratic term
    a3      = Parameter()               #Damage exponent

    function run_timestep(p, v, d, t)
        #Define function for DAMFRAC
        v.DAMFRAC[t] = p.a1 * p.TATM[t] + p.a2 * p.TATM[t] ^ p.a3
    
        #Define function for DAMAGES
            v.DAMAGES[t] = p.YGROSS[t] * v.DAMFRAC[t]
        end
    end