#' @importFrom grDevices dev.off pdf png
#' @importFrom graphics abline plot
#' @importFrom stats as.dist hclust quantile sd
#' @importFrom utils data installed.packages methods write.table
#' @importFrom methods new
.openDev <- function(fileName, devType, ...)
{
  if(devType=="pdf")
    pdf(paste0(fileName, ".pdf"), ...)

  if(devType=="png")
    png(paste0(fileName, ".png"), ...)

  if(devType=="cairo_pfd") # similar to Cairo::CairoPDF?
    grDevices::cairo_pdf(paste0(fileName, ".pdf"), ...)
}

.openDevHeatmap <- function(fileName, devType)
{
  if(devType!="pdf")
  {
    if(devType=="png") .openDev(fileName=fileName, devType=devType, width=1200,height=1200)
    if(devType!="png") .openDev(fileName=fileName, devType=devType)
    fileName <- NA
  }else{
    fileName <- paste0(fileName,".pdf")
  }
  return(fileName)
}

.closeDevHeatmap <- function(devType)
{
  if(devType!="pdf")
  {
    dev.off()
  }
}
