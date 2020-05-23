
"""
an illustration of eating a cake of finite and known size
"""

using JuMP,Ipopt,Plots,ReSHOP;

function non_renewable_resource()

    A = 1.0;        # chock price
    B = 0.5*0.5;    # unit cost
    T = 150;        # final period
    r = 0.05;       # interest rate
    S0 = 2.0;       # size of cake
    γ = 1.5;        # elasticity of substitution

    #model = Model(Ipopt.Optimizer)
    model = direct_model(ReSHOP.Optimizer(solver="knitro"))
    #model = Model(optimizer_with_attributes(ReSHOP.Optimizer, "solver"=>"KNITRO"))
    #model = Model(() -> ReSHOP.Optimizer(solver="knitro"))
    #model = Model(optimizer_with_attributes(ReSHOP.Optimizer, "solver"=>"pathnlp"))

    @variable(model, x[t=1:T]>=0)
    @variable(model, S[t=1:(T+1)]>=0)
    @constraint(model, [t=1:T], S[t+1] == - x[t] + S[t] )
    @constraint(model, [t=1], S[t] == 2.0 )
    @NLobjective(model, Max, sum( ((1+r)^(-t)) * (A*x[t] - B*x[t]^2) for t in 1:T))      # NON-RENEWABLE RESOURCE DEPLETION WITH LINEAR DEMAND
#    @NLobjective(model, Max, sum( ((1+r)^(-t)) * ((1/(1-γ))*x[t]^(1-γ)) for t in 1:T))  # CAKE EATING WITH ISOELASTIC PREFERENCES
    JuMP.optimize!(model);
    x,S=JuMP.value.(x),JuMP.value.(S);
    S = S[1:T]
    return(x,S)
end

@time x,S = non_renewable_resource()

gr()
plot(S,x)
