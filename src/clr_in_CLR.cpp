#include <Rcpp.h>
using namespace Rcpp;
#include <iostream>
//using namespace std;
#include <algorithm>
#include <ctime>
#include <cmath>
#include <vector>
#include <map>
#include <R.h>
#include <Rdefines.h>
#include <R_ext/Rdynload.h>
//' @export
// [[Rcpp::export]]
SEXP clrr( SEXP Rmim, SEXP Rsize,SEXP RskipDiagonal)
{
  const double *mim;
  const int *size;
  double *res, *avg, *var, tmp, zi, zj;
  unsigned int n,skipDiagonal;
  SEXP Rres, Ravg, Rvar;
  PROTECT(Rmim = AS_NUMERIC(Rmim));
  PROTECT(Rsize= AS_INTEGER(Rsize));
  PROTECT(RskipDiagonal= AS_INTEGER(RskipDiagonal));
  mim = NUMERIC_POINTER(Rmim);
  size= INTEGER_POINTER(Rsize);
	n=*size;
  skipDiagonal = *(INTEGER_POINTER(RskipDiagonal));
  PROTECT(Rres=NEW_NUMERIC(n*n));
  PROTECT(Ravg=NEW_NUMERIC(n));
  PROTECT(Rvar=NEW_NUMERIC(n));
  res = NUMERIC_POINTER(Rres);
  avg = NUMERIC_POINTER(Ravg);
  var = NUMERIC_POINTER(Rvar);

  for(unsigned int i=0; i<n*n; ++i )
    res[i]=0;
      //compute mean and variance
  for(unsigned int i = 0; i < n; ++i)
  {
    avg[i]=0;
    for(unsigned int j = 0; j < n; ++j)
    {
			if(i != j || skipDiagonal == 0) //skip the diagonal
        avg[i] += mim[i*n+j];
    }
    avg[i] /= (n - skipDiagonal); //-1 for skipping the diagonal
    var[i]=0;
    for(unsigned int j = 0; j < n; ++j)
    {
      if(i != j || skipDiagonal == 0) //skip the diagonal
      {
        tmp = (mim[i*n+j]-avg[i]);
        var[i] += tmp*tmp;
      }
    }
    var[i] /= (n - 1 - skipDiagonal); //bug fix variance should be n - 1 //another -1 for the diagonal skipping
  }
  //build network
  for(unsigned int i=1; i<n; ++i)
  {
    for(unsigned int j=0; j<i; ++j)
    {
			if(i == j && skipDiagonal == 1) //skip the diagonal
      {
        res[i*n+j] = 0;
      }
      else
      {
	      tmp = (mim[i*n+j] - avg[i]);
		    if(tmp < 0)
          zi = 0;
		    else
          zi = tmp*tmp/var[i];
		    tmp = (mim[i*n+j] - avg[j]);
		    if( tmp<0 )
          zj = 0;
	  	  else
          zj = tmp*tmp/var[j];
		    res[i*n+j] = sqrt(zi+zj); //bug fix zi and zj are already zi^2 and zj^2
		    res[j*n+i] = res[i*n+j]; //no need recalculate matrix is symetric
      }
	  }
  }
  UNPROTECT(6);
  return Rres;
}
