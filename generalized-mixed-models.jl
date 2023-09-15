using MixedModels

cbpp = dataset(:cbpp)


#proportions, binomial, logistic
mod_cbpp = fit(MixedModel, #proportion 'response' of 'success'
            @formula((incid/hsz) ~ 1 + period + (1|herd)),
          cbpp, Binomial(), LogitLink(); 
            wts=cbpp.hsz) #weights are total number of trials/observations - this is a must


verbagg=dataset(:verbagg) #Bernoilli() (1-0 data)
mod_verbagg = fit(MixedModel, #proportion 'response' 
            @formula(r2 ~ 1 + anger+gender+btype+situ + (1|subj) +(1|item)),
          verbagg, Bernoulli())

ticks = dataset(:grouseticks)
#Poisson() for count data, dataset: grouseticks

mod_ticks = fit(MixedModel, #proportion 'response' 
            @formula(ticks ~ 1 + year + (1|index) +(1|brood)+(1|location)),
          ticks, Poisson())


