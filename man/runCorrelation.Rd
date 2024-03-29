% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/runCorrelation.R
\name{runCorrelation}
\alias{runCorrelation}
\title{runCorrelation}
\usage{
runCorrelation(exprMat_filtered, scenicOptions)
}
\arguments{
\item{exprMat_filtered}{Expression matrix (filtered)}

\item{scenicOptions}{Fields used: Intermediate file name "corrMat"}
}
\value{
Writes the output in the file name stored in: \code{getIntName(scenicOptions, "corrMat")}
}
\description{
Calculates the spearman correlation on the input expression matrix & saves the results in SCENIC format
#example
library(SCENIC)
scenicOptions <- readRDS("int/scenicOptions.Rds")

loomPath <- system.file(package="SCENIC", "examples/mouseBrain_toy.loom")
exprMat <- SCopeLoomR::get_dgem(SCopeLoomR::open_loom(loomPath))

genesKept <- loadInt(scenicOptions, "genesKept")
exprMatrix_filtered <- exprMat[genesKept,]
exprMat_filtered <- log2(exprMatrix_filtered+1)

runCorrelation(exprMat_filtered, scenicOptions)
}
\examples{
print("test")
}
