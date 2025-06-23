using Random

"""
    generate_clues(N=10, basetype=Clue, seed=42)
Used in `test/clues.jl` to generate random valid clues for `ZP.EINSTEINS_ZEBRA`.
"""
function generate_clues(N=10, basetype=Clue, seed=42, puzzle=ZP.EINSTEINS_ZEBRA)
    Random.seed!(seed)
    clues = []
    f(K) =
        for I in subtypes(K)
            if !isabstracttype(I)
                push!(clues, lowercase(string(nameof(I))) * "_clues" => "[\n" * join(["\t" * repr(rand(I, puzzle)) for _ in Base.OneTo(N)], ",\n") * "\n]")
            else
                f(I)
            end
        end
    f(basetype)

    return join([p.first * " = " * p.second for p in clues], "\n\n")
end
