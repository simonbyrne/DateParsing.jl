macro chk1(expr,T)
    quote
        x,i = $(esc(expr))
        if isnull(x)
            return $T(),i
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
    dy, i = @chk1 tryparsenext_base10(str,i,4) R
    c,  i = @chk1 tryparsenext_char(str,i,'-') R
    dm, i = @chk1 tryparsenext_base10(str,i,2) R
    c,  i = @chk1 tryparsenext_char(str,i,'-') R
    dd, i = @chk1 tryparsenext_base10(str,i,2) R
    c,  i = @chk1 tryparsenext_char(str,i,('T',' ')) R
    th, i = @chk1 tryparsenext_base10(str,i,2) R
    c,  i = @chk1 tryparsenext_char(str,i,':') R
    tm, i = @chk1 tryparsenext_base10(str,i,2) R
    c,  i = @chk1 tryparsenext_char(str,i,':') R
    ts, i = @chk1 tryparsenext_base10(str,i,2) R

    nc, i = tryparsenext_char(str,i,'.')
    if isnull(nc)
        d = DateTime(dy,dm,dd,th,tm,ts)
    else
        tms,i = @chk1 tryparsenext_base10_frac(str,i,3) R
        d = DateTime(dy,dm,dd,th,tm,ts,tms)
    end
    return R(d), i
end

@inline function tryparsenext_base10_digit(str,i)
    R = Nullable{Int}
    done(str,i) && return R(), i
    c,ii = next(str,i)
    '0' <= c <= '9' || return R(), i
    return R(c-'0'), ii
end

@inline function tryparsenext_base10(str,i,n)
    R = Nullable{Int}
    r = 0
    for j = 1:n
        d,i = @chk1 tryparsenext_base10_digit(str,i) R
        r = r*10 + d
    end
    return R(r), i
end

@inline function tryparsenext_base10_frac(str,i,maxdig)
    R = Nullable{Int}
    r,i = @chk1 tryparsenext_base10_digit(str,i) R
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
end


@inline function tryparsenext_char(str,i,cc::Char)
    R = Nullable{Char}
    done(str,i) && return R(), i
    c,ii = next(str,i)
    c == cc || return R(), i
    R(c), ii
end
@inline function tryparsenext_char(str,i,CC::Tuple{Char,Char})
    R = Nullable{Char}
    done(str,i) && return R(), i
    c,ii = next(str,i)
    c == CC[1] || c == CC[2] || return R(), i
    R(c), ii
end
