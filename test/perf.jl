using Base.Test

d = DateTime("2016-02-19T12:34:56")
datestr = map(string,range(d,Dates.Millisecond(123),5_000_000))

using DateParsing

println("Testing DateParsing.parse")
@time a1 = DateParsing.parse(datestr)
@time a1 = DateParsing.parse(datestr)
@time a1 = DateParsing.parse(datestr)

println("Testing DateParsing.fastparse")
@time a2 = DateParsing.fastparse(datestr)
@time a2 = DateParsing.fastparse(datestr)
@time a2 = DateParsing.fastparse(datestr)

@test a1 == a2


println("Testing Base.DateTime on a 1/100th")
subset = 1:100:length(datestr)
datestr = datestr[subset]


function testDateTime{S<:AbstractString}(ads::Vector{S})
    l = length(ads)
    a = Array(DateTime, l)
    for i in 1:l
        a[i] = DateTime(ads[i])
    end
    a
end

@time a3 = testDateTime(datestr)
@time a3 = testDateTime(datestr)
@time a3 = testDateTime(datestr)

@test a1[subset] == a3
