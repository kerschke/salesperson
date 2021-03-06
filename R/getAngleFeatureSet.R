#' Feature: statistics of angles between nodes and their two nearest neighbors.
#'
#' @template arg_network
#' @param feature.set [\code{character}]\cr
#'   Subset of angle feature sets that should be computed. Possible choices are
#'   \code{"angle"} (statistics based on the angles between nodes and their two
#'   nearest neighbors) and \code{"cos"} (statistics based on the cosine of the
#'   aforementioned angles). Per default (\code{NULL}), both feature sets will
#'   be computed.
#' @param drop.duplicates [\code{logical(1)}]\cr
#'   Should duplicated node coordinates be dropped?
#'   Default is \code{FALSE}.
#' @template arg_include_costs
#' @details In case \code{include.costs = TRUE} the output will provide up to three
#'   separate cost values: one for the initialization phase, and one for each of the
#'   feature sets that were defined in \code{feature.set}. As the initialization
#'   phase is a mandatory prerequisite for computing either of the two feature sets,
#'   the user will manually have to add the costs of the initialization phase to the
#'   costs of the respective feature set(s).
#' @return [\code{list}]
#' @export
getAngleFeatureSet = function(x, feature.set = NULL, drop.duplicates = FALSE, include.costs = FALSE) {
  assertClass(x, "Network")
  assertSubset(feature.set, choices = c("angle", "cos"))
  if (is.null(feature.set))
    feature.set = c("angle", "cos")
  assertFlag(drop.duplicates)

  ## initialize by computing the angles between the nearest neighbors
  angles = measureTime(expression({
    coordinates = x$coordinates
    distance.matrix = as.matrix(x$distance.matrix)
    if (drop.duplicates) {
      idx.dups = which(duplicated(coordinates))
      if (length(idx.dups) > 0L) {
        warningf("Removing duplicated node coordinates.")
        coordinates = coordinates[-idx.dups, , drop = FALSE]
        distance.matrix = distance.matrix[-idx.dups, ]
        distance.matrix = distance.matrix[, -idx.dups]
      }
    }
    list(angles = getAnglesToNearestNeighborsCPP(coordinates, distance.matrix))
  }), "angle_initialization", include.costs)

  ## add the initialization costs in case we want to include the costs
  if (include.costs)
    feats = list(angle_initialization_costs = angles$angle_initialization_costs)
  else
    feats = NULL

  ## compute the ratio of points defining the hull
  if ("angle" %in% feature.set) {
    feats = c(
      feats,
      measureTime(expression({
        computeStatisticsOnNumericVector(angles$angles, "angle")
      }), "angle", include.costs)
    ) 
  }
  
  ## compute the area of the convex hull
  if ("cos" %in% feature.set) {
    feats = c(
      feats,
      measureTime(expression({
        computeStatisticsOnNumericVector(cos(angles$angles), "angle_cos")
      }), "angle_cos", include.costs)
    ) 
  }

  return(feats)
}
