using ContinuousWavelets
using Test
using Revise, FFTW, Plots
@testset "ContinuousWavelets.jl" begin
    # Write your tests here.
end
xSize = 67; boundary=NullBoundary(); s=3.5; decreasing=1; wfc = wavelet(cDb2, s=s, boundary=boundary,decreasing=decreasing)
wfc = wavelet(dog0,s=s,boundary=boundary,decreasing=decreasing)
wfc = wavelet(morl,s=s,boundary=boundary, decreasing=decreasing)
# continuous 1-d; different scalings should lead to different sizes, different boundary condtions shouldn't
@testset "Construction Types" begin
    @testset "xSz=$xSize, b=$boundary, s=$s, d=$decreasing, wfc=$(wfc.waveType)" for xSize = (33, 67), boundary = (DEFAULT_BOUNDARY, padded, NaivePer), 
        s=[1, 2, 3.5, 8, 16], decreasing = [1, 1.5,4.0], 
        wfc in (wavelet(morl,s=s,boundary=boundary,
                        decreasing=decreasing),
                wavelet(dog0,s=s,boundary=boundary,decreasing=decreasing),
                wavelet(paul4,s=s,boundary=boundary,decreasing=decreasing),
                wavelet(cDb2, s=s, boundary=boundary,decreasing=decreasing)) 
        xc = rand(Float64,xSize)
        # the sizes are of course broken at this size, so no warnings needed
        yc = 3
        with_logger(ConsoleLogger(stderr, Logging.Error)) do
            yc = cwt(xc, wfc)
        end
        if typeof(wfc.waveType) <: Union{Morlet, Paul}
            @test Array{ComplexF64, 2}==typeof(yc)
        else
            @test Array{Float64, 2}==typeof(yc)
        end
        nOctaves, totalWavelets, sRanges, sWidths =
            getNWavelets(xSize, wfc)
        @test totalWavelets == size(yc, 2)
    end
end
# TODO: test actual values, e.g. delta spike versus generating the wavelets
#       test averaging types
#            various extra dimensions
