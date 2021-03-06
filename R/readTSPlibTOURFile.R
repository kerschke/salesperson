#' Extract tour from TSPlib tour file.
#'
#' @param file.path [\code{character(1)}]\cr
#'   Path to TSPlib tour file.
#' @return [\code{list}] List with components \code{tour} and \code{tour.length}.
#' @export
readTSPlibTOURFile = function(file.path) {
  assertFile(file.path, access = "r")
  con = file(file.path, "r")

  # close connection on exit
  on.exit(close(con))

  tour = numeric()
  tour.length = NA

  lines = readLines(con)
  obj = list()
  i = 1L
  while (stringr::str_detect(lines[i], ":")) {
    spec = unlist(strsplit(lines[i], "[[:space:]]*:[[:space:]]*"))
    if (stringr::str_detect(spec[2], "Length")) {
      # If there is a line COMMENT: Length = <tour-length>
      # extract the <tour-length>
      tour.length = as.numeric(unlist(strsplit(spec[2], "[[:space:]]*=[[:space:]]*"))[2])
    }
    obj[[spec[1]]] = spec[2]
    i = i + 1L
  }
  # skip TOUR_SECTION line
  i = i + 1L

  #INFO: LKH tours contain the negative of the first node ID as the last element
  while (lines[i] != "EOF" && as.numeric(lines[i]) > 0) {
    tour = c(tour, as.integer(lines[i]))
    i = i + 1L
  }
  return(list(tour = as.integer(tour), tour.length = tour.length))
}
