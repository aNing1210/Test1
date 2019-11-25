#' @description This is a brief description.
#'
#' @title This is a title
#'
# @param x explanation of \code{x}
# @param ... explanation of \code{...}
#' @return The value returned by this function.
#' @author Who are you?
#' @seealso \code{\link[tools]{file_ext}}, \code{\link[tools]{file_path_sans_ext}}
#' @references \url{https://github.com/yihui/rmini}
#' @importFrom tools file_ext file_path_sans_ext
#' @export
#' @examples hi()
#'
#'
#'
hi <- function() {
  print("Hello, world!")
}
#split_filename = function(x, ...) {
#  c(file_path_sans_ext(x, ...), file_ext(x))
#}


## you do not need to export all objects

#' Scrolling letters
#'
#' Nothing fancy.
#' @param n length of letters
#' @return The last vector of letters.
#' @export
#' @examples library(rmini); rock_fun(); rock_fun(50)
#' # you can call unexported functions with ::: but it is not recommended
#' # because package authors may not want you to go into their backyards
#' rmini:::add_one(c('a', 'b', 'c'))







