using ZebraPuzzles
using ZebraPuzzles: ZebraPuzzles as ZP
using Logging

@test !ZP.issolved(ZP.UNSOLVED_EINSTEINS_ZEBRA)

let puz = deepcopy(ZP.UNSOLVED_EINSTEINS_ZEBRA)
  pop!(puz.clues)
  @test_logs (:warn, r".*does not have a unique solution.*") (:info, r".*add new clues.*") solve!(puz)
end
