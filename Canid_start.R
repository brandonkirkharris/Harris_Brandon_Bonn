####----------------------------------------------------------------------------
####Part One: Upload Data and load packages
{
  library(ggplot2)                                                              ##For plotting non-metric mds and admixture
  library(dplyr)                                                                ##For selecting specific rows/columns with select/filter
  library(ape)                                                                  ##For phylogenetic tree analysis
  library(ggtree)                                                               ##For phylogenetic tree visuals
  library(viridis)                                                              ##For visible graphical output
  library(jntools)                                                              ##Derives order of specimens on edge of a tree
  library(tidyr)                                                                ##For gather function in structure plot step
  library(ggpubr)                                                               ##for ggarrange

}
##upload snp tables. Upload only a few at a time for memory
work_dir          <- "./r5_busco"
master            <- read.table("./Specimen.tsv"                                ,           sep = "\t", header = T)
master_y          <- read.table("./Specimen-Y.tsv"                              ,           sep = "\t", header = T)
master_M          <- read.table("./Specimen-M.tsv"                              ,           sep = "\t", header = T)
wfst              <- read.table(paste(work_dir,"/wfst.tsv"                      , sep=""),  sep = "\t", header = T)
pfst              <- read.table(paste(work_dir,"/pfst.tsv"                      , sep=""),  sep = "\t", header = T)
wfst_yvg          <- read.table(paste(work_dir,"/wfst-yvg.tsv"                  , sep=""),  sep = "\t", header = T)
pfst_yvg          <- read.table(paste(work_dir,"/pfst-yvg.tsv"                  , sep=""),  sep = "\t", header = T)


depth             <- read.table(paste(work_dir,"/all-depth.tsv"                 , sep=""),  sep = "\t", header = T)
ygbb              <- read.table(paste(work_dir,"/yel-glw-BBAA.tsv"              , sep=""),  sep = "\t", header = T)


busco_eigenvec    <- read.table(paste(work_dir,"/busco-pca.eigenvec"            , sep=""),  sep = "\t", header = F)
busco_eigenval    <- read.table(paste(work_dir,"/busco-pca.eigenval"            , sep=""),              header = F)
busco_nwk         <- read.tree(paste(work_dir,"/RAxML_busco.nwk"                , sep="")                         )
busco_cv          <- read.table(paste(work_dir,"/busco-admix-cv.txt"            , sep=""),  sep = " " , header = F)
busco_mds         <- read.table(paste(work_dir,"/busco-mds.mds"                 , sep=""),  sep = ""  , header = T)
busco_BBAA        <- read.table(paste(work_dir,"/busco_BBAA.txt"                , sep=""),  sep = ""  , header = T)
chrY_eigenvec     <- read.table(paste(work_dir,"/chrY-pca.eigenvec"             , sep=""),  sep = "\t", header = F)
chrY_eigenval     <- read.table(paste(work_dir,"/chrY-pca.eigenval"             , sep=""),              header = F)
chrY_nwk          <- read.tree(paste(work_dir,"/RAxML_chrY.nwk"                 , sep="")                         )
chrY_cv           <- read.table(paste(work_dir,"/chrY-admix-cv.txt"             , sep=""),  sep = " " , header = F)
chrY_mds          <- read.table(paste(work_dir,"/chrY-mds.mds"                  , sep=""),  sep = ""  , header = T)
ogs_eigenvec      <- read.table(paste(work_dir,"/ogs-pca.eigenvec"              , sep=""),  sep = "\t", header = F)
ogs_eigenval      <- read.table(paste(work_dir,"/ogs-pca.eigenval"              , sep=""),              header = F)
ogs_nwk           <- read.tree(paste(work_dir,"/RAxML_ogs.nwk"                  , sep="")                         )
ogs_cv            <- read.table(paste(work_dir,"/ogs-admix-cv.txt"              , sep=""),  sep = " " , header = F)
ogs_mds           <- read.table(paste(work_dir,"/ogs-mds.mds"                   , sep=""),  sep = ""  , header = T)
ogs_BBAA          <- read.table(paste(work_dir,"/ogs_BBAA.txt"                  , sep=""),  sep = ""  , header = T)



##Prepare workspace for official gene set
{
    title             <- "Official gene set, 559,638 SNPs"
    marker            <- "ogs"
    BBAA              <- ogs_BBAA
    pca_snp           <- ogs_eigenvec
    eigenval          <- ogs_eigenval
    snp.nm.df         <- ogs_mds     
    specimen          <- master            
    wolf.phylo        <- ogs_nwk     
    cv                <- ogs_cv      
    admix_dir         <- paste(work_dir,"/",marker,"-admix", sep="")
    fst               <- pfst[,c(1,2,7,8)]
    colnames(fst)     <- c("Pop1", "Pop2", "Mean", "Weighted")
}

##Prepare workspace for busco
{
  title             <- "busco, 326,899 SNPs"         
  marker            <- "busco"
  BBAA              <- busco_BBAA
  pca_snp           <- busco_eigenvec
  eigenval          <- busco_eigenval
  snp.nm.df         <- busco_mds     
  specimen          <- master            
  wolf.phylo        <- busco_nwk     
  cv                <- busco_cv      
  admix_dir         <- paste(work_dir,"/",marker,"-admix", sep="")
  fst               <- pfst[,c(1,2,3,4)]
  colnames(fst)     <- c("Pop1", "Pop2", "Mean", "Weighted")
}
##Prepare workspace for chrY
{
  title             <- "ChrY, 208,104 SNPs"
  marker            <- "chrY"
  pca_snp           <- chrY_eigenvec
  eigenval          <- chrY_eigenval
  snp.nm.df         <- chrY_mds     
  specimen          <- master_y            
  wolf.phylo        <- chrY_nwk     
  cv                <- chrY_cv      
  admix_dir         <- paste(work_dir,"/",marker,"-admix", sep="")
  fst               <- pfst[,c(1,2,5,6)]
  colnames(fst)     <- c("Pop1", "Pop2", "Mean", "Weighted")
}


##References
{
  citation("ggplot2")                                                              
  citation("dplyr")       
  citation("ape")         
  citation("ggtree")      
  citation("viridis")     
  citation("jntools")     
  citation("tidyr")       
}
packageVersion("ggplot2")
packageVersion("dplyr") 
packageVersion("ape")   
packageVersion("ggtree")
packageVersion("viridis")
packageVersion("jntools")
packageVersion("tidyr")                                                          

citation("stats")
citation("MASS")
citation("ggbiplot")
packageVersion("ggbiplot")  
packageVersion("MASS")
