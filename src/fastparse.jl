function fastparse(str::ASCIIString)
    dy = 0
    for i = 1:4
        c = str[i]
        dy = 10*dy + (c - '0')
    end

    dm = 0
    for i = 6:7
        c = str[i]
        dm = 10*dm + (c - '0')
    end

    dd = 0
    for i = 9:10
        c = str[i]
        dd = 10*dd + (c - '0')
    end

    th = 0
    for i = 12:13
        c = str[i]
        th = 10*th + (c - '0')
    end

    tm = 0
    for i = 15:16
        c = str[i]
        tm = 10*tm + (c - '0')
    end

    ts = 0
    for i = 18:19
        c = str[i]
        ts = 10*ts + (c - '0')
    end

    tms = 0
    for i = 21:23
        if i <= length(str)
            c = str[i]
        else
            c = '0'
        end
        tms = 10*tms + (c - '0')
    end
    DateTime(dy,dm,dd,th,tm,ts,tms)
end


function fastparse{S<:AbstractString}(ads::Vector{S})
    l = length(ads)
    a = Array(DateTime, l)
    for i in 1:l
        a[i] = fastparse(ads[i])
    end
    a
end
