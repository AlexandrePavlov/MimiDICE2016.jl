#Timestep conversion function
function getindexfromyear_dice_2016(year)
    baseyear = 2015

    if rem(year - baseyear, 5) != 0
        error("Invalid year")
    end

    return div(year - baseyear, 5) + 1
end



#Get parameters from DICE2016 excel sheet
#range is the range of cell values on the excel sheet and must be a string, "B56:B77"
#parameters = :single for just one value, or :all for entire time series
#sheet is the sheet in the excel file to reference (i.e. "Base")
#T is the length of the time period (i.e 100)

#example:   getparams("B15:BI15", :all, "Base",  100)


function getparams(f, range::String, parameters::Symbol, sheet::String, T)

    if parameters == :single
        data = f[sheet][range]
        vals = Float64(data[1])

    elseif parameters == :all
        data = f[sheet][range]
        s = size(data)

        if length(s) == 2 && s[1] == 1
            # convert 2D row vector to 1D col vector
            data = vec(data)
        end

        dims = length(size(data))
        vals = Array{Float64, dims}(data)
    end

    return vals
end