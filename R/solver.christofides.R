#' @export
makeTSPSolver.christofides = function() {
  makeTSPSolverInternal(
    cl = "christofides",
    short.name = "chris",
    name = "Christofides 2/3 approximation",
    properties = c("euclidean", "external", "requires.tsplib", "deterministic")
  )
}

#' @export
# @interface see runTSPSolver
run.christofides = function(solver, instance, ...) {
  callAustralianSolverInterface(instance, bin = solver$bin, solver = "CHRIS")
}
