## "rules" ##

using ZebraPuzzles.Satisfiability
using ZebraPuzzles: ZebraPuzzles as ZP

s_exprs = ZP.AttributeExprs(ZP.EINSTEINS_ZEBRA)
@test all(contains(string(s_exprs[a]), first(split(string(a), " "))) for a in attributes(ZP.EINSTEINS_ZEBRA)) # Correct indexing into the AttributeExprs struct

u_exprs = ZP.AttributeExprs(ZP.UNSOLVED_EINSTEINS_ZEBRA)
@test all(contains(string(u_exprs[a]), first(split(string(a), " "))) for a in attributes(ZP.UNSOLVED_EINSTEINS_ZEBRA)) # Correct indexing into the AttributeExprs struct


@test :SAT == sat!(ZP.rules(ZP.EINSTEINS_ZEBRA)[2]) # => Base rules are satisfiable 
@test begin # => Rules do not allow two attributes of a single type linked to same subject
    exprs, rules = ZP.rules(ZP.EINSTEINS_ZEBRA)
    :UNSAT == sat!([rules..., exprs[House("red")] == exprs[House("yellow")]])
end
@test begin # => Rules do not allow larger link ids than the number of subjects and smaller than one
    exprs = ZP.AttributeExprs(ZP.EINSTEINS_ZEBRA)
    # NOTE: Rules must be generated for both because the `sat!` function mutates <10-06-25> 
    outofbounds = (:UNSAT == sat!([ZP.rules(exprs)..., exprs[House("red")] == 0])) &&
                  (:UNSAT == sat!([ZP.rules(exprs)..., exprs[House("red")] == nrow(ZP.EINSTEINS_ZEBRA) + 1]))
    inbounds = (:SAT == sat!([ZP.rules(exprs)..., exprs[House("red")] == 1])) && (:SAT == sat!([ZP.rules(exprs)..., exprs[House("red")] == nrow(ZP.EINSTEINS_ZEBRA)]))
    outofbounds && inbounds
end
