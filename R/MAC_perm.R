#' @title MAC_perm of LEAP Constructing Gene Co-Expression Networks for Single-Cell RNASequencing Data Using Pseudotime Ordering
#'
#' @description Function to perform a permutation analysis to determine a cutoff for significant MAC values.
#'
#' @param data A data matrix for which the rows are genes and the columns are experiments, sorted by their pseudotime
#' @param MACs_observ The resulting matrix of MACs from running MAC_counter on the dataset
#' @param num_perms The number of permutations to be performed. Default is 100.
#' @param max_lag_prop The largest proportion of your experiments that you want the size of the lag to be. Recommended not to go beyond 1/3. Default value is 1/3.
#' @param FDR_cutoffs The number of cutoffs between 0 and 1 to use for FDR analysis. Default value is 101, resulting in 0,0.01,0.02,...,0.98,0.99,1.
#' @param perm_file_name The name to be used for resulting .csv file. I.e., using perm_file_name="mine" would create the file "perm_mine.csv"
#' @return Returns a dataset with four columns: cors are the correlation cutoffs, MACs_observed are
#' the number of observed correlations at that cutoff, MACs_ave_perm are the average number observed in the
#' permuted datasets at that cutoff, and fdr is the false discovery rate (FDR) observed at that cutoff.
#' @importFrom utils write.csv
#' @examples
#' x <- matrix(rnorm(6),2,3)
#' cor <- cor(x)
#' y <- MAC_perm(x, cor)
#' @export
#'
MAC_perm <-
  function(data, MACs_observ, num_perms=100, max_lag_prop=1/3, FDR_cutoffs=101, perm_file_name=F){

    MACs_perm = c()

    # simplified MAC_counter function


    for(n in (1:num_perms)){

      set.seed(n)
      samp_size=min(100, nrow(data))
      data_perm = data[1:samp_size,]
      inds = sample(1:nrow(data),samp_size)

      for(z in (1:samp_size)){

        data_perm[z,] = sample(data[inds[z],])
      }

      results=MAC_lags(data=data_perm, max_lag_prop=1/3, symmetric=F)
      results_MACs=results[,1:nrow(data_perm)]
      MACs_perm = c(MACs_perm, results_MACs)

    }


    ### Calculate FDR ###

    cors = seq(0,1,length.out=FDR_cutoffs)

    num.cors.perm = rep(0, FDR_cutoffs)
    MACs_observed = rep(0, FDR_cutoffs)

    for(r in (1:FDR_cutoffs)){

      num.cors.perm[r] = num.cors.perm[r] + length(which(MACs_perm >= cors[r]))

      MACs_observed[r] = MACs_observed[r] + length(which(MACs_observ >= cors[r]))

    }

    perm.size=length(which(is.na(results_MACs)==F))
    obs.size=length(which(is.na(MACs_observ)==F))

    MACs_ave_perm = num.cors.perm/num_perms*(obs.size/perm.size)

    fdr = rep(NA,FDR_cutoffs)

    for(s in (1:FDR_cutoffs)){

      fdr[s] = MACs_ave_perm[s]/MACs_observed[s]

    }

    fdr[is.na(fdr)] = 0

    results = cbind(cors, MACs_observed, MACs_ave_perm, fdr)
    results_rev = results[FDR_cutoffs:1,]

    if(perm_file_name!=F){
      perm_name = paste(c("perm_", perm_file_name, ".csv"), sep="", collapse="")
      write.csv(results_rev, file = perm_name, row.names=F)
    }else{return(results_rev)}

  }
