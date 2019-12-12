#' @title build.mim   Build Mutual Information Matrix
#'
#' @description \code{build.mim} build.mim takes the dataset as input and computes the mutual information beetween all
#' pair of variables according to the mutual inforamtion estimator estimator. The results are saved in the mutual
#' information matrix (MIM), a square matrix whose (i,j) element is the mutual information between variables Xi and Xj.
#'
#' @param dataset data.frame containing gene expression data or any dataset where columns contain
#' variables/features and rows contain outcomes/samples.
#' @param estimator The name of the entropy estimator to be used. The package can use the four mutual information
#' estimators implemented in the package "infotheo": "mi.empirical", "mi.mm", "mi.shrink", "mi.sg" and three
#' estimators based on correlation: "pearson","spearman","kendall"(default:"spearman")
#' @param disc The name of the discretization method to be used with one of the discrete
#' estimators: "none", "equalfreq", "equalwidth" or "globalequalwidth" (default : "none") - see infotheo package.
#' @param nbins Integer specifying the number of bins to be used for the discretization if disc is
#' different from "none". By default the number of bins is set to pm where m is the number of samples.
#'
#'
#' @return build_mim returns the mutual information matrix.
#' @importFrom stats cor
#' @examples
#' data(syn.data)
#' mim <- build.mim(syn.data,estimator="spearman")
#'
#' @export
build.mim <- function( dataset, estimator = "spearman", disc = "none", nbins = sqrt(NROW(dataset)))
{
  if( disc == "equalfreq" || disc == "equalwidth" || disc == "globalequalwidth")
    dataset<-infotheo::discretize(dataset, disc, nbins)
  if( estimator=="pearson" || estimator=="spearman" || estimator=="kendall") {
    mim<-cor(dataset,method=estimator,use="complete.obs")^2
    diag(mim)<-0
    maxi<-0.999999
    mim[which(mim>maxi)]<-maxi
    mim <--0.5*log(1-mim)
  }

  else if(estimator == "mi.mm")
    estimator = "mm"
  else if(estimator == "mi.empirical")
    estimator = "emp"
  else if(estimator == "mi.sg")
    estimator = "sg"
  else if (estimator == "mi.shrink")
    estimator = "shrink"
  else
    stop("unknown estimator")

  if( estimator=="mm" || estimator=="emp" || estimator=="sg" || estimator=="shrink") {
    mim <-infotheo::mutinformation(dataset,method=estimator)
    diag(mim) <- 0
  }
  mim[mim<0]<-0
  mim
}
