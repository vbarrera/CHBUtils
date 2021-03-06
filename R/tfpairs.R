#' Get mouse TF-target pairs from opossum database
#' @import RSQLite
#' @param listgene vector with ensembl ID genes 
#' @param upstream limit distance of the TF to the TSS
#' (upstream to the TSS). 
#' @param downstream limit distance of the TF to the TSS
#' (downstream to the TSS). 
#' @param filesqlite sqlite file containgin the DB.
#' @return data.frame with TF-target pairs
#' @export
getTFpairs<-function(listgenes,
                     filesqlite,
                     upstream=10000,
                     downstream=0)
{
  if ( length(grep("ENSMUSG",listgenes))==0){
    print("your ids are not ensembl ids.")
  }else{
    require(RSQLite)
    sqlite    <- dbDriver("SQLite")
    db <- dbConnect(sqlite,filesqlite)
    gettf<-lapply(listgenes,function(x){
      
      xi<-as.numeric(gsub("^0{1,}","",sub("ENSMUSG","",x)))
      #print(x)
      tf <- dbGetQuery(db, 
                       paste0("select tf,score,con from mousetfpairs where dist > ",
                              -1 * downstream," and dist < ",upstream,
                              " and gene = ",xi,";"))
      if (nrow(tf)>0){
        #data.frame(gene=x,tf=intersect(tf[,1],row.names(mrlog)))
        data.frame(gene=x,tf=tf[,1],score=tf[,2],con=tf[,3])
      }else{
        return(NULL)
      }
    })
    tfpairs<-do.call(rbind,gettf)
    tfpairs[!duplicated(tfpairs),]
  }
}
