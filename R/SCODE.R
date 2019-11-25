#' @title SCODE  an efficient regulatory network inference algorithm from single-cell RNA-Seq during differentiation
#'
#' @description \code{SCODE} This function Optimize linear ODE and infer regulatory network from time course data.
#'
#' @param Input_file1 G x C matrix of expression data,Each row corresponds to each gene, and each column corresponds to each cell.
#' @param Input_file2 Time point data (e.g. pseudo-time data).
#' Col1 : Information of a cell (e.g. index of a cell, experimental time point)
#' Col2 : Time parameter (e.g. pseudo-time) (normalized from 0.0 to 1.0)
#'
#' @param G The number of transcription factors
#' @param D The number of expression patterns for the genes
#' @param C The number of cells
#' @param I The number of iterations of optimization
#'
#' @return G x G matrix, which corresponds to infered regulatory network. Aij represents the regulatory relationship from TF j to TF i.
#' @importFrom stats runif
#' @importFrom MASS ginv
#' @importFrom stats lm
#' @importFrom utils read.table
#' @examples
#' data(syn.exp)
#' data(syn.time)
#' A <- SCODE(syn.exp, syn.time, 100,4,356,100)
#' @export


SCODE <- function(Input_file1, Input_file2, G, D, C, I){
  maxB <- 2.0
  minB <- -10.0

  if(G > nrow(Input_file1)){
    G = nrow(Input_file1)
    print("G is larger than nrow(Input_file1)")
  }

  if(C > ncol(Input_file1)){
    C <- ncol(Input_file1)
    print("C is larger than ncol(Input_file1)")
  }

  #X <- as.matrix(read.table(Input1, sep="\t"))[1:G,1:C]
  X <- as.matrix(Input_file1)
  W <- matrix(rep(0,G*D), nrow=G, ncol=D)
  Z <- matrix(rep(0,D*C), nrow=D, ncol=C)
  WZ <- matrix(nrow=G, ncol=C)

  #read pseudo-time and normalize pseudo-time
  #pseudotime <- read.table(Input_file2, sep="\t")[1:C,2]
  pseudotime <- as.matrix(Input_file2)[1:C,2]
  pseudotime <- pseudotime/max(pseudotime)

  new_B <- rep(0, D)
  old_B <- rep(0, D)

  #initialization
  RSS <- Inf
  for(i in 1:D){
    new_B[i] <- runif(1, min=minB, max=maxB)
    old_B[i] <- new_B[i]
  }

  #optimize W and B iteratively
  for(ite in 1:I){
    #sampling B
    target <- floor(runif(1, min=1, max=D+1))
    new_B[target] <- runif(1, min=minB, max=maxB)

    #for last calculation
    if(ite == I){
      for(i in 1:D){
        new_B[i] <- old_B[i]
      }
    }

    #sample Z from new B
    for(i in 1:D){
      for(j in 1:C){
        Z[i,j] <- exp(new_B[i]*pseudotime[j]) + runif(1, min=-0.001, max=0.001)
      }
    }

    #regression
    for(i in 1:G){
      X.lm <- lm(X[i,] ~ t(Z)-1)
      for(j in 1:D){
        W[i,j] <- X.lm$coefficients[j]
      }
      WZ[i,] <- W[i,] %*% Z
    }

    #RSS
    tmp_RSS <- sum((X-WZ)**2)
    if(tmp_RSS < RSS){
      RSS <- tmp_RSS
    }
    else{
      new_B[target] <- old_B[target]
    }
  }

  #infer A
  B <- matrix(rep(0,D*D), nrow=D, ncol=D)
  for(i in 1:D){
    B[i,i] <- new_B[i]
  }
  invW <- ginv(W)
  A <- W %*% B %*% invW
}
