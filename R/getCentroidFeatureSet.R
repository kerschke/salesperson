#' Feature: Centroid coordinates and statistics of distances to centroid.
#'
#' @template arg_network
#' @template arg_include_costs
#' @return [\code{list}]
#' @export
getCentroidFeatureSet = function(x, include.costs = FALSE) {
  assertClass(x, "Network")
  measureTime(expression({
    centroid.coordinates = getCentroidCoordinatesCPP(x$coordinates)
    distances.to.centroid = getDistancesToCentroidCPP(x$coordinates, centroid.coordinates)
    c(list(
      "centroid_x" = centroid.coordinates[1],
      "centroid_y" = centroid.coordinates[2]
      ), computeStatisticsOnNumericVector(distances.to.centroid, "centroid"))
  }), "centroid", include.costs)
}
