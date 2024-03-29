#' @title GENIE3 GEne Network Inference with Ensemble of Trees
#'
#' @description \code{GENIE3} Infers a gene regulatory network (in the form of a weighted adjacency matrix) from expression data, using ensembles of regression trees.
#'
#' @param exprMatrix Expression matrix (genes x samples). Every row is a gene, every column is a sample.
#' The expression matrix can also be provided as one of the Bioconductor classes:
#' \itemize{
#' \item \code{ExpressionSet}: The matrix will be obtained through exprs(exprMatrix)
#' \item \code{RangedSummarizedExperiment}: The matrix will be obtained through assay(exprMatrix), wich will extract the first assay (usually the counts)
#' }
#' @param regulators Subset of genes used as candidate regulators. Must be either a vector of indices, e.g. \code{c(1,5,6,7)}, or a vector of gene names, e.g. \code{c("at_12377", "at_10912")}. The default value NULL means that all the genes are used as candidate regulators.
#' @param targets Subset of genes to which potential regulators will be calculated. Must be either a vector of indices, e.g. \code{c(1,5,6,7)}, or a vector of gene names, e.g. \code{c("at_12377", "at_10912")}. If NULL (default), regulators will be calculated for all genes in the input matrix.
#' @param treeMethod Tree-based method used. Must be either "RF" for Random Forests (default) or "ET" for Extra-Trees.
#' @param K Number of candidate regulators randomly selected at each tree node (for the determination of the best split). Must be either "sqrt" for the square root of the total number of candidate regulators (default), "all" for the total number of candidate regulators, or a stricly positive integer.
#' @param nTrees Number of trees in an ensemble for each target gene. Default: 1000.
#' @param nCores Number of cores to use for parallel computing. Default: 1.
#' @param verbose If set to TRUE, a feedback on the progress of the calculations is given. Default: FALSE.
#' @useDynLib Test1, .registration = TRUE
#' @return Weighted adjacency matrix of inferred network. Element w_ij (row i, column j) gives the importance of the link from regulatory gene i to target gene j.
#' @importFrom stats setNames
#' @importFrom Biobase ExpressionSet
#' @docType methods
#' @rdname GENIE3-methods
#' @examples
#' ## Generate fake expression matrix
#' exprMatrix <- matrix(sample(1:10, 100, replace=TRUE), nrow=20)
#' rownames(exprMatrix) <- paste("Gene", 1:20, sep="")
#' colnames(exprMatrix) <- paste("Sample", 1:5, sep="")
#'
#' ## Run GENIE3
#' set.seed(123) # For reproducibility of results
#' weightMatrix <- GENIE3(exprMatrix, regulators=paste("Gene", 1:5, sep=""))
#'
#' ## Get ranking of edges
#' linkList <- getLinkList(weightMatrix)
#' head(linkList)
#' @export
#'
#'
#'

setGeneric("GENIE3", signature="exprMatrix",
           function(exprMatrix, regulators=NULL, targets=NULL,
                    treeMethod="RF", K="sqrt", nTrees=1000,
                    nCores=1, verbose=FALSE)
           {
             standardGeneric("GENIE3")
           })

#' @export
#' @rdname GENIE3-methods
#' @aliases GENIE3-methods matrix
setMethod("GENIE3", "matrix",
          function(exprMatrix, regulators=NULL, targets=NULL, treeMethod="RF", K="sqrt", nTrees=1000, nCores=1, verbose=FALSE)
          {
            .GENIE3(exprMatrix=exprMatrix, regulators=regulators, targets=targets, treeMethod=treeMethod, K=K, nTrees=nTrees, nCores=nCores, verbose=verbose)
          })

#' @export
#' @rdname GENIE3-methods
#' @aliases GENIE3-methods SummarizedExperiment
setMethod("GENIE3", "SummarizedExperiment",
          function(exprMatrix, regulators=NULL, targets=NULL, treeMethod="RF", K="sqrt", nTrees=1000, nCores=1, verbose=FALSE)
          {
            if(length(SummarizedExperiment::assays(exprMatrix))>1) warning("More than 1 assays are available. Only using the first one.")
            exprMatrix <- SummarizedExperiment::assay(exprMatrix)
            .GENIE3(exprMatrix=exprMatrix, regulators=regulators, targets=targets, treeMethod=treeMethod, K=K, nTrees=nTrees, nCores=nCores, verbose=verbose)
          })

#' @export
#' @rdname GENIE3-methods
#' @aliases GENIE3-methods ExpressionSet
setMethod("GENIE3", "ExpressionSet",
          function(exprMatrix, regulators=NULL, targets=NULL, treeMethod="RF", K="sqrt", nTrees=1000, nCores=1, verbose=FALSE)
          {
            exprMatrix <- Biobase::exprs(exprMatrix)
            .GENIE3(exprMatrix=exprMatrix, regulators=regulators, targets=targets, treeMethod=treeMethod, K=K, nTrees=nTrees, nCores=nCores, verbose=verbose)
          })

.GENIE3 <- function(exprMatrix, regulators, targets, treeMethod, K, nTrees, nCores, verbose)
{
  .checkArguments(exprMatrix=exprMatrix, regulators=regulators, targets=targets, treeMethod=treeMethod, K=K, nTrees=nTrees, nCores=nCores, verbose=verbose)

  if(is.numeric(regulators)) regulators <- rownames(exprMatrix)[regulators]

  ############################################################
  # transpose expression matrix to (samples x genes)
  exprMatrixT <- t(exprMatrix); rm(exprMatrix)
  num.samples <- nrow(exprMatrixT)
  allGeneNames <- colnames(exprMatrixT)

  # get names of input genes
  if(is.null(regulators))
  {
    regulatorNames <- allGeneNames
  } else
  {
    # input gene indices given as integers
    if (is.numeric(regulators))
    {
      regulatorNames <- allGeneNames[regulators]
      # input gene indices given as names
    } else
    {
      regulatorNames <- regulators
      # for security, abort if some input gene name is not in gene names
      missingGeneNames <- setdiff(regulatorNames, allGeneNames)
      if (length(missingGeneNames) != 0) stop(paste("Regulator genes missing from the expression matrix:", paste(missingGeneNames, collapse=", ")))
    }
  }
  regulatorNames <- sort(regulatorNames)
  rm(regulators)

  # get names of target genes
  if(is.null(targets))
  {
    targetNames <- allGeneNames
  } else
  {
    # input gene indices given as integers
    if (is.numeric(targets))
    {
      targetNames <- allGeneNames[targets]
      # input gene indices given as names
    } else
    {
      targetNames <- targets
      # for security, abort if some input gene name is not in gene names
      missingGeneNames <- setdiff(targetNames, allGeneNames)
      if (length(missingGeneNames) != 0) stop(paste("Target genes missing from the expression matrix:", paste(missingGeneNames, collapse=", ")))
    }
  }
  targetNames <- sort(targetNames)
  nGenes <- length(targetNames)
  rm(targets)

  # tree method
  if (treeMethod == 'RF')
  {
    RF_randomisation <- 1
    ET_randomisation <- 0
    bootstrap_sampling <- 1
  } else {
    RF_randomisation <- 0
    ET_randomisation <- 1
    bootstrap_sampling <- 0
  }

  if (verbose) message(paste("Tree method: ", treeMethod,
                             "\nK: ", K,
                             "\nNumber of trees: ", nTrees, sep=""))
  # other default parameters
  nmin <- 1
  permutation_importance <- 0

  # setup weight matrix
  weightMatrix <- matrix(0.0, nrow=length(regulatorNames), ncol=length(targetNames))
  rownames(weightMatrix) <- regulatorNames
  colnames(weightMatrix) <- targetNames

  # compute importances for every target gene
  if(nCores==1)
  {
    # serial computing
    if(verbose) message("Using 1 core.")
    for(targetName in targetNames)
    {
      if(verbose) message(paste("Computing gene ", which(targetNames == targetName), "/", nGenes, ": ",targetName, sep=""))

      # remove target gene from input genes
      theseRegulatorNames <- setdiff(regulatorNames, targetName)
      numRegulators <- length(theseRegulatorNames)
      mtry <- .setMtry(K, numRegulators)

      x <- exprMatrixT[,theseRegulatorNames]
      y <- exprMatrixT[,targetName]

      im <- .C("BuildTreeEns", as.integer(num.samples),as.integer(numRegulators),
               as.single(c(x)),as.single(c(y)),as.integer(nmin),
               as.integer(ET_randomisation),as.integer(RF_randomisation),
               as.integer(mtry),as.integer(nTrees),
               as.integer(bootstrap_sampling),as.integer(permutation_importance),
               as.double(vector("double",numRegulators)))[[12]]

      # normalize variable importances
      im <- im / sum(im)
      weightMatrix[theseRegulatorNames, targetName] <- im
    }
  } else
  {
    # requireNamespace("foreach"); requireNamespace("doRNG"); requireNamespace("doParallel")

    # parallel computing
    doParallel::registerDoParallel(); options(cores=nCores)
    if(verbose) message(paste("\nUsing", foreach::getDoParWorkers(), "cores."))

    # weightMatrix.reg <- foreach::foreach(targetName=targetNames, .combine=cbind) %dorng%
    "%dopar%"<- foreach::"%dopar%"
    suppressPackageStartupMessages(weightMatrix.reg <- doRNG::"%dorng%"(foreach::foreach(targetName=targetNames, .combine=cbind),
                                                                        {
                                                                          # remove target gene from input genes
                                                                          theseRegulatorNames <- setdiff(regulatorNames, targetName)
                                                                          numRegulators <- length(theseRegulatorNames)
                                                                          mtry <- .setMtry(K, numRegulators)

                                                                          x <- exprMatrixT[,theseRegulatorNames]
                                                                          y <- exprMatrixT[,targetName]

                                                                          im <- .C("BuildTreeEns", as.integer(num.samples), as.integer(numRegulators),
                                                                                   as.single(c(x)),as.single(c(y)), as.integer(nmin),
                                                                                   as.integer(ET_randomisation), as.integer(RF_randomisation),
                                                                                   as.integer(mtry), as.integer(nTrees),
                                                                                   as.integer(bootstrap_sampling), as.integer(permutation_importance),
                                                                                   as.double(vector("double",numRegulators)))[[12]]

                                                                          # normalize variable importances
                                                                          im <- im / sum(im)

                                                                          c(setNames(0, targetName), setNames(im, theseRegulatorNames))[regulatorNames]
                                                                        }))
    attr(weightMatrix.reg, "rng") <- NULL
    weightMatrix[regulatorNames,] <- weightMatrix.reg[regulatorNames,]
  }

  # weightMatrix[which(weightMatrix < 0, arr.ind=TRUE)] <- 0

  return(weightMatrix)
}

# mtry <- setMtry(K, numRegulators)
.setMtry <- function(K, numRegulators)
{
  # set mtry
  if (class(K) == "numeric") {
    mtry <- K
  } else if (K == "sqrt") {
    mtry <- round(sqrt(numRegulators))
  } else {
    mtry <- numRegulators
  }

  return(mtry)
}

.checkArguments <- function(exprMatrix, regulators, targets, treeMethod, K, nTrees, nCores, verbose)
{
  ############################################################
  # check input arguments
  if (!is.matrix(exprMatrix) && !is.array(exprMatrix)) {
    stop("Parameter exprMatrix must be a two-dimensional matrix where each row corresponds to a gene and each column corresponds to a condition/sample/cell.")
  }

  if (length(dim(exprMatrix)) != 2) {
    stop("Parameter exprMatrix must be a two-dimensional matrix where each row corresponds to a gene and each column corresponds to a condition/sample/cell.")
  }

  if (is.null(rownames(exprMatrix))) {
    stop("exprMatrix must contain the names of the genes as rownames.")
  }

  countGeneNames <- table(rownames(exprMatrix))
  nonUniqueGeneNames <- countGeneNames[countGeneNames>1]
  if(length(nonUniqueGeneNames)>0)
    stop("The following gene IDs (rownames) are not unique: ", paste(names(nonUniqueGeneNames), collapse=", "))

  if (treeMethod != "RF" && treeMethod != "ET") {
    stop("Parameter treeMethod must be \"RF\" (Random Forests) or \"ET\" (Extra-Trees).")
  }

  if (K != "sqrt" && K != "all" && !is.numeric(K)) {
    stop("Parameter K must be \"sqrt\", or \"all\", or a strictly positive integer.")
  }

  if (is.numeric(K) && K<1) {
    stop("Parameter K must be \"sqrt\", or \"all\", or a strictly positive integer.")
  }

  if (!is.numeric(nTrees) || nTrees<1) {
    stop("Parameter nTrees should be a stricly positive integer.")
  }

  if (!is.null(regulators))
  {
    if(length(regulators)<2) stop("Provide at least 2 potential regulators.")

    if (!is.vector(regulators)) {
      stop("Parameter 'regulators' must a vector (of indices or gene names).")
    }

    if (is.numeric(regulators)) {
      if(max(regulators) > nrow(exprMatrix)) stop("At least one index in 'regulators' exceeds the number of genes.")
      if(min(regulators) <= 0) stop("The indexes in 'regulators' should be >=1.")
    }

    if(any(table(regulators)>1))
      stop("Please, provide each regulator (name/ID) only once.")

    if (is.character(regulators)){
      regulatorsInMatrix <- intersect(regulators, rownames(exprMatrix))
      if(length(regulatorsInMatrix) == 0)
        stop("The genes must contain at least one regulators")

      if(length(regulatorsInMatrix) < length(regulators))
        warning("Only", length(regulatorsInMatrix), "out of", length(regulators), " candidate regulators (IDs/names) are in the expression matrix.")
    }
  }

  if (!is.null(targets))
  {
    if (!is.vector(targets)) {
      stop("Parameter 'targets' must a vector (of indices or gene names).")
    }

    if (is.numeric(targets)) {
      if(max(targets) > nrow(exprMatrix)) stop("At least one index in 'targets' exceeds the number of genes.")
      if(min(targets) <= 0) stop("The indexes in 'targets' should be >=1.")
    }

    if(any(table(targets)>1))
      stop("Please, provide each target (name/ID) only once.")

    if (is.character(targets)){
      targetsInMatrix <- intersect(targets, rownames(exprMatrix))
      if(length(targetsInMatrix) == 0)
        stop("The genes must contain at least one targets.")


      if(length(targetsInMatrix) < length(targets))
        warning("Only", length(targetsInMatrix), "out of", length(targets), "target genes (IDs/names) are in the expression matrix.")
    }
  }

  if (!is.numeric(nCores) || nCores<1)
  {
    stop("Parameter nCores should be a stricly positive integer.")
  }
}



#' @title getLinkList
#'
#' @description \code{getLinkList} Converts the weight matrix, as returned by \code{\link{GENIE3}}, to a sorted list of regulatory links (most likely links first).
#'
#' @param weightMatrix Weighted adjacency matrix as returned by \code{\link{GENIE3}}.
#' @param reportMax Maximum number of links to report. The default value NULL means that all the links are reported.
#' @param threshold Only links with a weight equal or above the threshold are reported. Default: threshold = 0, i.e. all the links are reported.
#'
#' @return List of regulatory links in a data frame. Each line of the data frame corresponds to a link. The first column is the regulatory gene, the second column is the target gene, and the third column is the weight of the link.
#'
#' @seealso \code{\link{GENIE3}}
#'
#' @examples
#' ## Generate fake expression matrix
#' exprMat <- matrix(sample(1:10, 100, replace=TRUE), nrow=20)
#' rownames(exprMat) <- paste("Gene", 1:20, sep="")
#' colnames(exprMat) <- paste("Sample", 1:5, sep="")
#'
#' ## Run GENIE3
#' weightMat <- GENIE3(exprMat, regulators=paste("Gene", 1:5, sep=""))
#'
#' ## Get ranking of edges
#' linkList <- getLinkList(weightMat)
#' head(linkList)
#' @export
getLinkList <- function(weightMatrix, reportMax=NULL, threshold=0) {
  if(!is.numeric(threshold)) {
    stop("threshold must be a number.")
  }

  # Only process weights off-diagonal
  regulatorsInTargets <- rownames(weightMatrix)[rownames(weightMatrix) %in% colnames(weightMatrix)]
  if(length(regulatorsInTargets)==1) weightMatrix[regulatorsInTargets, regulatorsInTargets] <- NA
  if(length(regulatorsInTargets)>1) diag(weightMatrix[regulatorsInTargets, regulatorsInTargets]) <- NA

  linkList <- reshape2::melt(weightMatrix, na.rm=TRUE)
  colnames(linkList) <- c("regulatoryGene", "targetGene", "weight")
  linkList <- linkList[linkList$weight>=threshold,]
  linkList <- linkList[order(linkList$weight, decreasing=TRUE),]

  if(!is.null(reportMax)) {
    linkList <- linkList[1:min(nrow(linkList), reportMax),]
  }
  rownames(linkList) <- NULL

  uniquePairs <- nrow(unique(linkList[,c("regulatoryGene", "targetGene")]))
  if(uniquePairs < nrow(linkList))
    warning("There might be duplicated regulator-target (gene id/name) pairs.")

  return(linkList)
}
