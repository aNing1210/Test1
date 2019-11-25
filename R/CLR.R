#' @title CLR Context Likelihood or Relatedness Network
#'
#' @description \code{CLR} clr takes the mutual information matrix as input in order to return the infered network
#'
#' @param mim A square matrix whose i,j th element is the mutual information between variables Xi and Xj
#' @param skipDiagonal Skips the diagonal in the calculation of the mean and sd. Default=1.
#'
#' @return clr returns a matrix which is the weighted adjacency matrix of the network. In order to display
#' the network, load the package Rgraphviz and use the following comand plot( as( returned.matrix,"graphNEL") )
#' @useDynLib Test1, .registration = TRUE
#' @examples
#' data(syn.data)
#' mim <- build.mim(syn.data,estimator="spearman")
#' net <- clr(mim)
#'
#' @export
#'
#'
#'
clr<- function( mim,skipDiagonal=1)
{
  var.id<-NULL
  if(is.data.frame(mim)) {
    var.id <- names(mim)
    mim <- as.matrix(mim)
  }
  else if( is.matrix(mim) )
    var.id <- names(as.data.frame(mim))
  else stop("Supply a matrix-like argument")
  if(ncol(mim)!=nrow(mim))
    stop("Argument matrix must be square")
  if(!isSymmetric(mim)) #added extra check to verify matrix symetric
    stop("Please enter a symetric matrix")
  res <- .Call( "clr", mim, nrow(mim),skipDiagonal,PACKAGE="Test" )
  dim(res) <- dim(mim)
  res <- as.matrix(res)
  rownames(res) <- var.id
  colnames(res) <- var.id
  res
}
