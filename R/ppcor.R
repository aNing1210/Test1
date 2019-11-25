#' @description This is a brief description of pcor.
#'
#' @title This is a title of pcor
#' @param x a matrix or data frame
#' @param method a character string indicating which partial correlation coefficient is to be computed
#' @return a matrix of the partial correlation coefficient between two variables,
#' a matrix of the p value of the test,a matrix of the value of the test statistic,
#' the number of samples, the number of given variables, the correlation method used
#' @author Who are you?
#' @importFrom stats cov cov2cor pnorm pt
#' @importFrom MASS ginv
#' @export
#'
#' @examples
#' y.data <- data.frame(hl=c(7,15,19,15,21,22,57,15,20,18),
#' disp=c(0.000,0.964,0.000,0.000,0.921,0.000,0.000,1.006,0.000,1.011),
#' deg=c(9,2,3,4,1,3,1,3,6,1),
#' BC=c(1.78e-02,1.05e-06,1.37e-05,7.18e-03,0.00e+00,0.00e+00,0.00e+00,4.48e-03,2.10e-06,0.00e+00))
#' pcor(y.data)
#'
#'
#'
pcor <- function(x, method = c("pearson", "kendall", "spearman"))
{
  # correlation method
  method <- match.arg(method)

  # check the data
  if (is.data.frame(x))
    x <- as.matrix(x)
  if (!is.matrix(x))
    stop("supply a matrix-like 'x'")
  if (!(is.numeric(x) || is.logical(x)))
    stop("'x' must be numeric")
  stopifnot(is.atomic(x))

  # sample number
  n <- dim(x)[1]

  # given variables' number
  gp <- dim(x)[2]-2

  # covariance matrix
  cvx <- cov(x,method=method)

  # inverse covariance matrix
  if(det(cvx) < .Machine$double.eps){
    warning("The inverse of variance-covariance matrix is calculated using Moore-Penrose generalized matrix invers due to its determinant of zero.")
    icvx <- ginv(cvx)
  }else
    icvx <- solve(cvx)

  # partial correlation
  pcor <- -cov2cor(icvx)
  diag(pcor) <- 1

  # p-value
  if(method == "kendall"){
    statistic <- pcor/sqrt(2*(2*(n-gp)+5)/(9*(n-gp)*(n-1-gp)))
    p.value <- 2*pnorm(-abs(statistic))

  }else{
    statistic <- pcor*sqrt((n-2-gp)/(1-pcor^2))
    p.value <- 2*pt(-abs(statistic),(n-2-gp))
    #p.value <- 2*pnorm(-abs(statistic))
  }

  diag(statistic) <- 0
  diag(p.value) <- 0

  list(estimate=pcor,p.value=p.value,statistic=statistic,n=n,gp=gp,method=method)
}



#' @description This is a brief description of pcor.test
#'
#' @title This is a title of pcor.test
#' @param x explanation of x
#' @param y explanation of y
#' @param z explanation of z
#' @param method explanation of method
#' @return The value returned by this function.
#' @author Who are you?
#' @export
#'
#' @examples
#' y.data <- data.frame(hl=c(7,15,19,15,21,22,57,15,20,18),
#' disp=c(0.000,0.964,0.000,0.000,0.921,0.000,0.000,1.006,0.000,1.011),
#' deg=c(9,2,3,4,1,3,1,3,6,1),
#' BC=c(1.78e-02,1.05e-06,1.37e-05,7.18e-03,0.00e+00,0.00e+00,0.00e+00,4.48e-03,2.10e-06,0.00e+00))
#' pcor.test(y.data$hl,y.data$disp,y.data[,c("deg","BC")])
#'
pcor.test <- function(x,y,z,method=c("pearson", "kendall", "spearman"))
{
  # The partial correlation coefficient between x and y given z
  #
  # pcor.test is free and comes with ABSOLUTELY NO WARRANTY.
  #
  # x and y should be vectors
  #
  # z can be either a vector or a matrix

  # correlation method
  method <- match.arg(method)

  x <- c(x)
  y <- c(y)
  z <- as.data.frame(z)

  # merge into a matrix
  xyz <- data.frame(x,y,z)

  # partial correlation
  pcor = pcor(xyz,method=method)

  data.frame(estimate=pcor$est[1,2],p.value=pcor$p.value[1,2],statistic=pcor$statistic[1,2],n=pcor$n,gp=pcor$gp,Method=method)
}
