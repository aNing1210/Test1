#' @title ARACNE  Algorithm for the Reconstruction of Accurate Cellular NEtworks
#'
#' @description \code{ARACNE} This function takes the mutual information matrix as input in order to return the
#' infered network according to the Aracne algorithm. This algorithm applies the data processing inequality to all
#' triplets of nodes in order to remove the least significant edge in each triplet.
#'
#' @param mim A square matrix whose i,j th element is the mutual information between variables Xi and Xj
#' @param eps Numeric value indicating the threshold used when removing an edge : for each
#' triplet of nodes (i,j,k), the weakest edge, say (ij), is removed if its weight is below min{(ik),(jk)}-eps
#'
#'
#' @return aracne returns a matrix which is the weighted adjacency matrix of the network. In order to display
#' the network, load the package Rgraphviz and use the following command: plot( as( returned.matrix ,"graphNEL") )
#' @useDynLib Test1, .registration = TRUE
#' @importFrom Rcpp sourceCpp
#' @examples
#' data(syn.data)
#' mim <- build.mim(syn.data,estimator="spearman")
#' net <- aracne(mim)
#'
#' @export
aracne <- function( mim, eps=0 )
{
  var.id<-NULL
  if(is.data.frame(mim)) {
    var.id <- names(mim)
    mim <- as.matrix(mim)
  }
  else if( is.matrix(mim) )
    var.id <- names(as.data.frame(mim))
  else stop("Supply a matrix-like argument")
  if(ncol(mim) != nrow(mim))
    stop("Argument matrix must be square")
  res <- .Call("_Test1_aracnee", mim, nrow(mim),eps,PACKAGE="Test1")
  #res <- aracnee(mim, nrow(mim),eps)
  dim(res) <- dim(mim)
  res <- as.matrix(res)
  rownames(res) <- var.id
  colnames(res) <- var.id
  res
}
