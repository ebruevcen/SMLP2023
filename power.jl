using DataFrames
using MixedModels
using MixedModelsSim
using MixedModelsMakie

using MixedModels: dataset

kb07=dataset(:kb07)

contrasts = Dict(:spkr => EffectsCoding(),
                :prec => EffectsCoding(),
                :load => EffectsCoding())
            
fm1 = fit(MixedModel, @formula(rt_trunc ~ 1 * spkr * prec * load + (1|subj) + (1|item)),
        kb07; contrasts)

pb1 = parametricbootstrap(MersenneTwister(42),1000, fm1; optsum_overrides =(;ftol_rel=1e-8)) #bootstrapping

#If our estimates in our model is correct, then how exactly it is applicable to 1000 times of this application, i.e., bootstrapping

## The idea behind parametric bootstap is to see what will happen if we simulate some data. We get the estimates from our model. -same data
##If so, we can also simulate different data, not dependent on our model, based on our predictions. Given the model specs we expect, we can simulate data, aka power. We could pass values, other realities to our simulation
#  parametricbootstrap([rng::AbstractRNG], nsamp::Integer, m::MixedModel{T}, ftype=T; β = coef(m), σ = m.σ, θ = m.θ, hide_progress=false, optsum_overrides=(;))

#β, σ  =sd , and other values θ= random effects


#simdat_crossed
#  simdat_crossed([RNG], subj_n, item_n; subj_btwn=nothing, item_btwn=nothing, both_win=nothing, subj_prefix="S", item_prefix="I")

subj_btwn = Dict(:age => ["old", "young"]) #between subjects
item_btwn = Dict(:frequency => ["low", "high"]) #within subjects, item between
subj_n = 30
item_n = 30

dat = simdat_crossed(MersenneTwister(666), subj_n, item_n; subj_btwn, item_btwn)

dat = DataFrame(dat)

simmod = fit(MixedModel, @formula(dv ~ 1 + age + frequency + age&frequency+ (1+frequency|subj) + (1+age|item)), dat)


#We want VarCorr to be closer to zero, as much as possible

#create_re -we can use this to Create things more naturally

β = [100.0, 50.0, 50.0, 25.0] #this is the coeeffcients, intercept, effect1, effect2, interaction (massive effects, this is the differnce from 0- the higher,closer it is, the more significant the predictor is. This is where 80 comes from???)
σ = 3.14 
subj_re = create_re(2.0, 1.3)
item_re = create_re(1,3, 2.0) #Where do these numbers come from? these are sd? Relative to SD???
θ = createθ(simmod; subj=subj_re, item=item_re)

#simulate!(simmod; β, σ, θ)
#simboot = parametricbootstrap

#DataFrame(simboot.coefpvalues) 

#ridgeplot(simboot)

#using CairoMakie -for (diagnostic) plots

#using Statistics , to group by and combine and calculate p values, power etc. 


β = [250.0, -25.0, 10, 0.0] #averag reaction time ; old people -25 sec slower, freq makes people 10 ms faster, no interaction effect
σ = 25.0  #residual variability of real world subjects
subj_re = create_re(2.0, 1.3)
item_re = create_re(1,3, 2.0) #Where do these numbers come from? these are sd?
θ = createθ(simmod; subj=subj_re, item=item_re)

coefpvalues = DataFrame()

rng = MersenneTwister(42)

for subj_n in [20, 30, 50 ,100]
    for item_n in [40, 60, 100]
            dat= simdat_crossed(MersenneTwister(666), subj_n, item_n; subj_btwn, item_btwn)
            simmod = fit(MixedModel, @formula(dv ~ 1 + age + frequency + age&frequency+ (1+frequency|subj) + (1+age|item)), dat)
            θ = createθ(simmod; subj=subj_re, item=item_re)
        
            simboot = parametricbootstrapp(rng, 1000, simmod; β, σ, θ, optsum_overrides =(;ftol_rel=1e-8))

            df = DataFrame(simboot.coefpvalues)
            df[!, :subj_n] .= subj_n
            df[!, :item_n] .= item_n
            append!(coefpvalues, df)
    end
end