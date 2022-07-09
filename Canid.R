####----------------------------------------------------------------------------
####Part Two: Dimension Compression
##Principal Component Analysis
pca_snp <- cbind(specimen$Population, pca_snp)                                  ##Add population layer to eigenvectors 
pca_snp <- pca_snp[-c(67),]                                                     ##Remove outliers from analysis (modify for each plot)
specimen <- specimen[-c(67),]  
rownames(pca_snp) <- specimen$Specimen                                          ##Replace names of eigenvectors with Specimens
pca <- ggplot(pca_snp, aes(x=V3, y=V4, fill= specimen$Population)) +            ##Aesthetics for mapping points to plot
  geom_point(aes(color = specimen$Population)) +                                ##Add points, color by population
  ##  geom_text(size = 3, aes(label = rownames(pca_snp))) +                         ##Add individual labels (optional)
  ##  xlim(-0.3, 0.3) +                                                             ##Set limits of x axis (modify for each plot)
  ##  ylim(-0.3, 0.5) +                                                             ##Set limits of y axis (modify for each plot)
  theme_bw() +                                                                  ##Change theme
  stat_ellipse(aes(color = specimen$Population, fill = specimen$Population),    ##Add ellipses, color based on population
               geom = "polygon", alpha = 0.25)  +                               ##Fill ellipses and make partially transparent
  xlab(paste("PC1 (", 100*(eigenval[1,]/sum(eigenval$V1)), "%)", sep="")) +     ##calculate proportion of variance from eigenval
  ylab(paste("PC2 (", 100*(eigenval[2,]/sum(eigenval$V1)), "%)", sep="")) +                                                                    
  theme(legend.title = element_blank(), legend.position = c(0.8,0.2)) +         ##Change legend aesthetics
  ggtitle(paste("PCA", title, sep = " "))

ggsave(plot = pca, filename = paste("PCA_", marker, ".png", sep = ""),          ##Save graph directly to directory
       width = 2000, height = 2000, units = "px",
       path = paste(work_dir,"/", marker, "-image", sep = ""))
specimen <- master                                                              ##Reset specimen file when done


##Non-metric multi-dimensional scaling
mds <- ggplot(snp.nm.df, 
              aes(x=C1, y=C2, fill= specimen$Population)) +                     ##Aesthetics for mapping points to plot
  geom_point(aes(color = specimen$Population)) +                                ##Add points, color by population
  ##  geom_text(size = 3, aes(label = rownames(pca_snp))) +                         ##Add individual labels (optional)
  ##  xlim(-0.3, 0.3) +                                                             ##Set limits of x axis (modify for each plot)
  ##  ylim(-0.3, 0.5) +                                                             ##Set limits of y axis (modify for each plot)
  theme_bw() +                                                                  ##Change theme
  stat_ellipse(aes(color = specimen$Population, fill = specimen$Population),    ##Add ellipses, color based on population
               geom = "polygon", alpha = 0.25)  +                               ##Fill ellipses and make partially transparent
  theme(legend.title = element_blank(), legend.position = c(0.8,0.2)) +         ##Change legend aesthetics
  labs(x = "Dimension 1", y = "Dimension 2") +
  ggtitle(paste("Non-Metric Multi-Dimensional Scaling for", title, sep = " "))

ggsave(plot = mds, filename = paste("MDS_", marker, ".png", sep = ""),          ##Save graph directly to directory
       width = 2000, height = 2000, units = "px",
       path = paste(work_dir,"/", marker, "-image", sep = ""))

####----------------------------------------------------------------------------
####Part Three: Fst values
##Pairwise fst
pf <- ggplot(fst, aes(x = Pop1, y = Pop2, fill = Weighted)) +
  geom_tile() + theme_light() +
  theme(panel.grid.minor = element_blank(), 
        panel.grid.major = element_blank(),
        axis.title = element_blank(),
        legend.position = c(0.8, 0.2)) +
  ggtitle(paste("Pairwise weighted Fst, ", marker, sep = "")) +
  geom_text(aes(label=round(Weighted, digits = 3)), color = "black", size = 4) +
  scale_fill_gradient(low="white", high="orange", name = "Fst")
##  scale_fill_viridis(discrete=F, name = "Fst")      

ggsave(plot = pf, width = 1500, height = 1500, units = "px",
       filename = paste("Pairwise weighted fst, ", marker, ".png", sep = ""),
       path = paste(work_dir,"/", marker, "-image", sep = ""))

##Whole population fst

wf <- ggplot(wfst, aes(x=Population, y=Weighted, fill=Marker)) +
  geom_bar(position = "dodge", stat="identity") +
  theme_bw() +
  ylab("Weighted Mean") +
  ggtitle("Weighted Mean Fst for subpopulations, all Markers") +
  geom_text(aes(label=round(Weighted, digits = 3)), 
            color = "black", size = 4, position=position_dodge(0.9),
            vjust = 1.5)
##  scale_y_continuous(breaks = -0.025:0.050)

ggsave(plot = wf, width = 3500, height = 2000, units = "px",
       filename = paste("wm_Fst.png", sep = ""),
       path = paste(work_dir, "/all-image", sep = ""))

####----------------------------------------------------------------------------
####Part Four: Phylogenetic Tree
wolf.phylo <- root(wolf.phylo, "SRR7976426", resolve.root = T)                  ##Root tree to Golden Jackal
wolf.phylo <- ladderize(wolf.phylo, right = F)                                  ##ladderize
order.phy  <- specimen[match(wolf.phylo$tip.label, specimen$SRR),]              ##Sort specimen table by tree node order
wolf.phylo$tip.label <- as.character(order.phy$Specimen)                        ##Replace the tree node names (SRR) with the Specimen names 

phy <- ggtree(wolf.phylo) + 
  theme_tree2() + 
  geom_point(aes(shape=isTip, color = isTip), size = 4, show.legend = F) +
  geom_text(aes(label = node), size = 2) +
  ##  geom_text(aes(label = label), size = 1, hjust = -0.3) +
  ggtitle(paste("Phylogenetic tree", marker, sep = " ")) +
  theme_bw() + 
  xlim(0,0.04) +                                                                ##0.004 for wgs+busco, 0.04 for chrY
  theme(panel.grid.minor = element_blank(), panel.grid.major = element_blank(), 
        axis.text.y = element_blank(), axis.ticks.y = element_blank(),
        plot.title=element_text(size = 10),
        axis.ticks.x = element_blank(), axis.text.x = element_blank()) +
  geom_tiplab(align=T, family="mono", linetype="dashed", size = 2.5)
  ##Paste clade labels here

ggsave(plot = phy, filename=paste("Phylogenetic Tree_",marker,".png",sep = ""), ##Save graph directly to directory
       width = 2000, height = 3000, units = "px",
       path = paste(work_dir,"/", marker, "-image", sep = ""))

####----------------------------------------------------------------------------
####Part Five: Admixture Results

cvplot <- ggplot(cv, aes(x = V1, y = V2)) +                                     ##Plot cross validation to decide best value of K
  geom_line() +
  theme_bw() +
  scale_x_continuous(breaks = 1:15) + 
  labs(x = "Assumed Ancestral Populations (K)", y = "Cross Validation Error") +
  ggtitle(paste("K Value Cross Validation,", marker, sep = " "))

ggsave(plot = cvplot, filename = paste("CV_", marker, ".png", sep = ""),        ##Save graph directly to directory
       width = 1500, height = 1090, units = "px",
       path = paste(work_dir,"/", marker, "-image", sep = ""))

##Admixture plots
ordered <- get_tips_in_ape_plot_order(wolf.phylo)                               ##Get specimen names in order plotted on tree

##test <- admix_15                                                              ##For analysis of single Q file
##x <- "7"
for (x in 1:15) {                                                               ##For loop to do all 15 levels of ancestry
  k <- paste("k",x,sep="")                                                      ##assumed ancestral populations
  test <- read.table(paste(admix_dir, "/", marker,".", x, ".Q" ,  
                           sep = ""), sep = " ", header = F)                    ##input table
  row.names(test) <- specimen$Specimen                                          ##Change row names of table to specimen name
  test <- as.data.frame(test[match(ordered, row.names(test)),])                 ##Order row names by order of specimens on tree
  row.names(test) <- c(1:76)                                                    ##Replace row names with numbers for ggplot to sort
  test <- as.data.frame(t(test))                                                ##Transform dataframe across its axis
  pop <- rownames(test)                                                         ##Create a variable called pop with the nownames (for ggplot or mutate???)
  muted <- test %>% mutate(pop = rownames(test))                                ##I don't know what this does but its necessary
  test_long <- gather(muted, key, value, -pop)                                  ##Create long-form table readable by geom_bar (key-value pairs)
  admix <- ggplot(test_long,                                                    ##Plot test_long
                  aes(x = as.numeric(key), y = value, fill = pop)) +            ##Aesthetics to plot
    geom_bar(position="stack", stat="identity") +                               ##Designate a stacked bar plot
    theme(axis.text.x = element_text(angle = 90)) +                             ##Angle labels perpendicular to plot
    scale_x_continuous(breaks = 1:76, labels = ordered) +                       ##Place labels onto continuous scale (so we can actually see them)
    coord_flip() +                                                              ##Flip coordinates so labels are on vertical axis
    theme_dendrogram(legend.position="none",                                    ##General formatting (remove legend)
                     axis.text=element_text(size=3),                            ##General formatting (change label size)
                     plot.title=element_text(hjust= 0.5, size = 10)) +          ##Format title size and position
    ggtitle(paste("Admixture", k, marker, sep = " "))                           ##Add title
  admix                                                                         ##View graph if necessary
  ggsave(plot = admix, filename = paste(marker, "_", k,".png", sep = ""),       ##Save graph directly to directory
         width = 1500, height = 1090, units = "px",
         path = paste(work_dir,"/", marker, "-image", sep = ""))
}
####----------------------------------------------------------------------------
####Part Six: Coverage and depth
filelist <- scan(paste(work_dir, "/", marker, "_covlist.txt", sep=""), 
                 what=character())                                              ##Upload list of files
cov_dir <- paste(work_dir, "/", marker, "-cov/", sep="")                        ##File location
cov_df <- data.frame(Specimen=character(),Coverage=double(),stringsAsFactors=F) ##Empty dataframe

for (indiv in filelist) {                                                       ##Loop start with curly bracket on same line :/
  cov  <- read.table(paste(cov_dir, indiv, sep=""), sep="\t", header=F)         ##read coverage table
  val <- weighted.mean(cov$V6, cov$V4)                                          ##Calculate weighted average
  name <- substring(indiv, 0, 10)                                               ##Extract name from file
  cov_df[nrow(cov_df) +1,] = c(name, val)                                       ##Append to dataframe
}
rm(cov_df)                                                                      ##Clear cov_df if restarting the loop, which appends.
write.table(cov_df, paste(work_dir, "/", marker, "_avg_cov.txt", sep = ""),
            sep="\t",row.names=FALSE)

dp <- ggplot(depth, aes(x=Specimen, y=Depth, fill=Marker)) +                    ##plot average depth
  geom_bar(position = "dodge", stat="identity") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = c(0.2,0.8)) +
  ylab("Average Depth") +
  ggtitle("Average Depth per sample")

ggsave(plot = dp, width = 3500, height = 2000, units = "px",
       filename = paste("avg_depth.png", sep = ""),
       path = paste(work_dir, "/all-image", sep = ""))


####----------------------------------------------------------------------------
