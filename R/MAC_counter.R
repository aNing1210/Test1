#' @title MAC_counter of LEAP Constructing Gene Co-Expression Networks for Single-Cell RNASequencing Data Using Pseudotime Ordering
#'
#' @description Function to perform lag-based correlation anaylsis of single-cell sequencing data, sorted by pseudotime.
#'
#' @param data A data matrix for which the rows are genes and the columns are experiments,sorted by their pseudotime
#' @param max_lag_prop The largest proportion of your experiments that you want the size of the lag to be.
#' Recommended not to go beyond 1/3. Default value is 1/3.
#' @param MAC_cutoff The lowest MAC desired to be shown in results. Default value is 0.2
#' @param file_name The name to be used for resulting .csv files. I.e., using file_name="mine"
#' would create the file "MAC_mine.csv" and "lag_mine.csv"
#' @param lag_matrix Logical. TRUE indicates that the resulting matrix of lags should be saved to a csv.
#' Default value is TRUE.
#' @param symmetric Logical. TRUE indicates that a symmetric matrix is required for output MAC.csv file.
#'  Results in the absolute maximum value for each pair (i,j) and (j,i). Default value is FALSE.
#' @return Returns a dataset with four columns: Row gene index and Column gene index correspond to the
#' indeces for the gene pair (i,j), Correlation is the maximum absolute correlation (MAC) achieved for
#' the pair, and Lag is the lag at which the MAC occurred.
#' @importFrom utils write.csv
#' @examples
#' x <- matrix(rnorm(6),2,3)
#' y <- MAC_counter(x)
#' @export
#'
MAC_counter <-
  function(data, max_lag_prop=1/3, MAC_cutoff=0.2, file_name=F, lag_matrix=T, symmetric=F){

    results=MAC_lags(data, max_lag_prop=max_lag_prop, symmetric=F)

    results_MACs=results[,1:nrow(data)]
    results_lags=results[,-(1:nrow(data))]

    # write files

    if(file_name!=F){
      if(symmetric==F){

        if(lag_matrix==T){
          lag_name = paste(c("lag_", file_name, ".csv"), sep="", collapse="")
          write.csv(results_lags, file=lag_name, row.names=F)
        }

        MAC_name = paste(c("MAC_", file_name, ".csv"), sep="", collapse="")
        write.csv(results_MACs, file=MAC_name, row.names=F)

      }else{

        # write files

        if(lag_matrix==T){
          lag_name = paste(c("lag_symmetric_", file_name, ".csv"), sep="", collapse="")
          write.csv(results_lags, file=lag_name, row.names=F)
        }

        MAC_name = paste(c("MAC_symmetric_", file_name, ".csv"), sep="", collapse="")
        write.csv(results_MACs, file=MAC_name, row.names=F)

      }
    }

    final_results = c()

    cors = sort(as.matrix(abs(results_MACs)), decreasing=T, na.last=NA)
    max_cors = cors[which(cors>=MAC_cutoff)]
    unique_cors = unique(max_cors)

    ind_cor = which(abs(results_MACs)>=MAC_cutoff)
    ind_rc = which(abs(results_MACs)>=MAC_cutoff, arr.ind=T)

    data_inds=cbind(abs(results_MACs[ind_cor]),results_MACs[ind_cor], results_lags[ind_cor],ind_rc[,1], ind_rc[,2])

    final_results=data_inds[order(data_inds[,1], decreasing = T),-1]

    colnames(final_results) = c("Correlation", "Lag", "Row gene index", "Column gene index")

    return(final_results)

  }
