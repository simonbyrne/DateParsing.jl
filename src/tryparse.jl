macro chk1(expr)
    quote
        x,i = $(esc(expr))
        if isnull(x)
            @goto err
        else
            get(x),i
        end
    end
end

function parse(str)
    nd, i = tryparsenext_datetime(str,1)
    if isnull(nd)
        throw(ParseError("Invalid DateTime"))
    end
    get(nd)
end


function parse{S<:AbstractString}(ads::Vector{S})
    l = length(ads)
    a = Array(DateTime, l)
    for i in 1:l
        a[i] = parse(ads[i])
    end
    a
end

function tryparsenext_datetime(str,i)
    R = Nullable{DateTime}
    dy, i = @chk1 tryparsenext_base10(str,i,4)
    c,  i = @chk1 tryparsenext_char(str,i,'-')
    dm, i = @chk1 tryparsenext_base10(str,i,2)
    c,  i = @chk1 tryparsenext_char(str,i,'-')
    dd, i = @chk1 tryparsenext_base10(str,i,2)
    c,  i = @chk1 tryparsenext_char(str,i,('T',' '))
    th, i = @chk1 tryparsenext_base10(str,i,2)
    c,  i = @chk1 tryparsenext_char(str,i,':')
    tm, i = @chk1 tryparsenext_base10(str,i,2)
    c,  i = @chk1 tryparsenext_char(str,i,':')
    ts, i = @chk1 tryparsenext_base10(str,i,2)

    nc, i = tryparsenext_char(str,i,'.')
    if isnull(nc)
        d = DateTime(dy,dm,dd,th,tm,ts)
    else
        tms,i = @chk1 tryparsenext_base10_frac(str,i,3)
        d = DateTime(dy,dm,dd,th,tm,ts,tms)
    end
    return R(d), i
    
    @label err
    return R(), i
end

@inline function tryparsenext_base10_digit(str,i)
    R = Nullable{Int}
    done(str,i) && @goto err
    c,ii = next(str,i)
    '0' <= c <= '9' || @goto err
    return R(c-'0'), ii

    @label err
    return R(), i
end

@inline function tryparsenext_base10(str,i,n)
    R = Nullable{Int}
    r = 0
    for j = 1:n
        d,i = @chk1 tryparsenext_base10_digit(str,i)
        r = r*10 + d
    end
    return R(r), i

    @label err
    return R(), i
end

@inline function tryparsenext_base10_frac(str,i,maxdig)
    R = Nullable{Int}
    r,i = @chk1 tryparsenext_base10_digit(str,i)
    for j = 2:maxdig
        nd, i = tryparsenext_base10_digit(str,i)
        if isnull(nd)
            for k = j:maxdig
                r *= 10
            end
            return R(r), i
        end
        d = get(nd)
        r = 10*r + d
    end
    return R(r),i

    @label err
    return R(), i    
end


@inline function tryparsenext_char(str,i,cc::Char)
    R = Nullable{Char}
    done(str,i) && @goto err
    c,ii = next(str,i)
    c == cc || @goto err
    return R(c), ii

    @label err
    return R(), i    
end
@inline function tryparsenext_char(str,i,CC::Tuple{Char,Char})
    R = Nullable{Char}
    done(str,i) && @goto err
    c,ii = next(str,i)
    c == CC[1] || c == CC[2] || @goto err
    return R(c), ii

    @label err
    return R(), i    
end
