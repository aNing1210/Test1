#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME: 
   Check these declarations against the C/Fortran source code.
*/

/* .C calls */
extern void BuildTreeEns(void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *);

/* .Call calls */
extern SEXP _Test1_aracnee(SEXP, SEXP, SEXP);
extern SEXP _Test1_calculate_conditioned_rdi_cpp_wrap(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_calculate_conditioned_rdi_multiple_run_cpp(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_calculate_conditioned_rdi_multiple_run_wrap(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_calculate_rdi_cpp(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_calculate_rdi_cpp_wrap(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_calculate_rdi_multiple_run_cpp(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_calculate_rdi_multiple_run_cpp_wrap(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_calculate_umi_cpp(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_calculate_umi_cpp_wrap(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_clr_scribe(SEXP);
extern SEXP _Test1_clrr(SEXP, SEXP, SEXP);
extern SEXP _Test1_cmi(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_di_single_run(SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_di_single_run_conditioned(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_digamma_0(SEXP);
extern SEXP _Test1_entropy(SEXP, SEXP);
extern SEXP _Test1_extract_max_rdi_value_delay(SEXP, SEXP);
extern SEXP _Test1_extract_top_incoming_nodes_delays(SEXP, SEXP, SEXP);
extern SEXP _Test1_kde(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_kde_cpp(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_knn_density(SEXP, SEXP, SEXP);
extern SEXP _Test1_knn_density_2d(SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_lmi_multiple_run(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_lmi_multiple_run_cpp(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_lmi_single_run(SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_mi(SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_rdi_many_runs(SEXP, SEXP, SEXP);
extern SEXP _Test1_rdi_multiple_run_cpp(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_rdi_multiple_runs_conditioned(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_rdi_multiple_runs_conditioned_cpp(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_rdi_single_run(SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_rdi_single_run_conditioned(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_smooth_gene(SEXP, SEXP);
extern SEXP _Test1_ucmi(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_ucmi_cpp(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_umi(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_umi_cpp(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _Test1_vd(SEXP);

static const R_CMethodDef CEntries[] = {
    {"BuildTreeEns", (DL_FUNC) &BuildTreeEns, 12},
    {NULL, NULL, 0}
};

static const R_CallMethodDef CallEntries[] = {
    {"_Test1_aracnee",                                     (DL_FUNC) &_Test1_aracnee,                                     3},
    {"_Test1_calculate_conditioned_rdi_cpp_wrap",          (DL_FUNC) &_Test1_calculate_conditioned_rdi_cpp_wrap,          6},
    {"_Test1_calculate_conditioned_rdi_multiple_run_cpp",  (DL_FUNC) &_Test1_calculate_conditioned_rdi_multiple_run_cpp,  7},
    {"_Test1_calculate_conditioned_rdi_multiple_run_wrap", (DL_FUNC) &_Test1_calculate_conditioned_rdi_multiple_run_wrap, 7},
    {"_Test1_calculate_rdi_cpp",                           (DL_FUNC) &_Test1_calculate_rdi_cpp,                           6},
    {"_Test1_calculate_rdi_cpp_wrap",                      (DL_FUNC) &_Test1_calculate_rdi_cpp_wrap,                      6},
    {"_Test1_calculate_rdi_multiple_run_cpp",              (DL_FUNC) &_Test1_calculate_rdi_multiple_run_cpp,              7},
    {"_Test1_calculate_rdi_multiple_run_cpp_wrap",         (DL_FUNC) &_Test1_calculate_rdi_multiple_run_cpp_wrap,         7},
    {"_Test1_calculate_umi_cpp",                           (DL_FUNC) &_Test1_calculate_umi_cpp,                           6},
    {"_Test1_calculate_umi_cpp_wrap",                      (DL_FUNC) &_Test1_calculate_umi_cpp_wrap,                      6},
    {"_Test1_clr_scribe",                                  (DL_FUNC) &_Test1_clr_scribe,                                  1},
    {"_Test1_clrr",                                        (DL_FUNC) &_Test1_clrr,                                        3},
    {"_Test1_cmi",                                         (DL_FUNC) &_Test1_cmi,                                         5},
    {"_Test1_di_single_run",                               (DL_FUNC) &_Test1_di_single_run,                               4},
    {"_Test1_di_single_run_conditioned",                   (DL_FUNC) &_Test1_di_single_run_conditioned,                   5},
    {"_Test1_digamma_0",                                   (DL_FUNC) &_Test1_digamma_0,                                   1},
    {"_Test1_entropy",                                     (DL_FUNC) &_Test1_entropy,                                     2},
    {"_Test1_extract_max_rdi_value_delay",                 (DL_FUNC) &_Test1_extract_max_rdi_value_delay,                 2},
    {"_Test1_extract_top_incoming_nodes_delays",           (DL_FUNC) &_Test1_extract_top_incoming_nodes_delays,           3},
    {"_Test1_kde",                                         (DL_FUNC) &_Test1_kde,                                         5},
    {"_Test1_kde_cpp",                                     (DL_FUNC) &_Test1_kde_cpp,                                     5},
    {"_Test1_knn_density",                                 (DL_FUNC) &_Test1_knn_density,                                 3},
    {"_Test1_knn_density_2d",                              (DL_FUNC) &_Test1_knn_density_2d,                              4},
    {"_Test1_lmi_multiple_run",                            (DL_FUNC) &_Test1_lmi_multiple_run,                            5},
    {"_Test1_lmi_multiple_run_cpp",                        (DL_FUNC) &_Test1_lmi_multiple_run_cpp,                        5},
    {"_Test1_lmi_single_run",                              (DL_FUNC) &_Test1_lmi_single_run,                              4},
    {"_Test1_mi",                                          (DL_FUNC) &_Test1_mi,                                          4},
    {"_Test1_rdi_many_runs",                               (DL_FUNC) &_Test1_rdi_many_runs,                               3},
    {"_Test1_rdi_multiple_run_cpp",                        (DL_FUNC) &_Test1_rdi_multiple_run_cpp,                        5},
    {"_Test1_rdi_multiple_runs_conditioned",               (DL_FUNC) &_Test1_rdi_multiple_runs_conditioned,               7},
    {"_Test1_rdi_multiple_runs_conditioned_cpp",           (DL_FUNC) &_Test1_rdi_multiple_runs_conditioned_cpp,           7},
    {"_Test1_rdi_single_run",                              (DL_FUNC) &_Test1_rdi_single_run,                              4},
    {"_Test1_rdi_single_run_conditioned",                  (DL_FUNC) &_Test1_rdi_single_run_conditioned,                  6},
    {"_Test1_smooth_gene",                                 (DL_FUNC) &_Test1_smooth_gene,                                 2},
    {"_Test1_ucmi",                                        (DL_FUNC) &_Test1_ucmi,                                        7},
    {"_Test1_ucmi_cpp",                                    (DL_FUNC) &_Test1_ucmi_cpp,                                    7},
    {"_Test1_umi",                                         (DL_FUNC) &_Test1_umi,                                         6},
    {"_Test1_umi_cpp",                                     (DL_FUNC) &_Test1_umi_cpp,                                     6},
    {"_Test1_vd",                                          (DL_FUNC) &_Test1_vd,                                          1},
    {NULL, NULL, 0}
};

void R_init_Test1(DllInfo *dll)
{
    R_registerRoutines(dll, CEntries, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
