#' Plots the pvalue quantiles against the uniform distribution. If adjusted pvalues are present, colors those that pass cutoff red 
#' @param pvaldf dataframe, required
#' @param pval_colid character string, column header of column containing unadjusted pvalues, required
#' @param adj_pval_colid character string, column header of column containing adjusted pvalues, required
#' @param adj_pval_cutoff, optional, defaults to 0.05
#' @param title, optional, defaults to "Quantile-quantile plot of p-values against Uniform distribution"
#' @export
#' @examples
#' qqplot_JH(df, pval_colid="pval", adj_pval_colid="padj", adj_pval_cutoff=0.05, title="My qqplot")

qqplot_JH = function(pvaldf,  pval_colid="pval", adj_pval_colid="padj", adj_pval_cutoff=0.05, title="Quantile-quantile plot of p-values against Uniform distribution") {
  require(ggplot2)
  title=title
  pvaldf <- pvaldf[order(pvaldf[,pval_colid], decreasing=F),]
  pvals <- as.vector(unlist(pvaldf[, pval_colid]))
  o <- -log10(pvals)
  e <- -log10( 1:length(o)/length(o) )
  
  if(adj_pval_colid %in% colnames(pvaldf)){
    padjs <- as.numeric(as.vector(unlist(pvaldf$padj)))
    colors <- as.vector(ifelse(padjs<adj_pval_cutoff, "sig", "nonsig"))
  } else {
    colors <- rep( "NA",length(pvals))
  }
  
  plot=qplot(e,o, color=colors, xlim=c(0,max(e[!is.na(e)])), ylim=c(0,max(o[!is.na(o)]))) + stat_abline(intercept=0,slope=1, col="darkgrey")
  plot=plot+labs(title=title)
  plot=plot+scale_x_continuous(name=expression(Expected~~-log[10](italic(p))))
  plot=plot+scale_y_continuous(name=expression(Observed~~-log[10](italic(p))))
  
  if(adj_pval_colid %in% colnames(pvaldf)){
    plot=plot + scale_colour_manual(name="BFH adjusted pvalue", values=c("black", "red"), labels=c(paste("q>", adj_pval_cutoff, sep=""),paste("q<", adj_pval_cutoff,sep="")))
    plot
  } else {
    plot=plot + scale_colour_manual(values=c("black"))
    plot=plot + theme(legend.position="none")
    plot
  }
}
