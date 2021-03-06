#!/usr/bin/env Rscript

require(dten)
getArgs<-function(){
  require(optparse)
  option_list <- list(
    make_option(c("-i", "--input"), dest='input',help='Tab-delimited file of protein names and weights'),
    make_option(c("-m", "--mu"), default=5e-04,dest='mu', help="Probability the cell types are unknown"),
    make_option(c("-o", "--output"), default=NULL, dest='output',help = "Prefix to add to output files"),
    make_option(c('-b','--beta'), default=1, dest='beta',help="How much to weight terminals"),
    make_option(c('-w','--w'),default=2, dest='w',help="Omega value to control how many trees are created in forest")
   )

  args=parse_args(OptionParser(option_list = option_list,usage="usage: %prog [options]",description= "Runs the PCSF algorithm using a data frame of selected proteins and weights selected under a condition of interest and saves to structured rds object"))
  if(is.null(args$output))
    args$output=gsub('tsv','rds',basename(args$input))

  return(args)
}

main<-function(){
  args<-getArgs()
  print(paste('Mapping',args$input,'to network in',args$output))
  dg<-dten::loadDrugGraph()
  ppi<-dten::buildNetwork(dg)
  tab<-read.table(args$input,sep='\t',header=T)
  prots<-tab$vals
  names(prots)<-tab$gene
  condition<-tab$condition[1]##assume condition is written in every file
  dummies<-dten::getDrugs(dg)

  pcsf.res<-dten::runPcsfWithParams(ppi,prots, dummies, w=args$w, b=args$beta, mu=args$mu,doRand=TRUE)
  pcsf.res <-dten::renameDrugIds(pcsf.res,dummies)

  enrich.res=data.frame()
  net=pcsf.res
#  try({
#      enrich=PCSF::enrichment_analysis(pcsf.res)
#      enrich.res<-enrich$enrichment
#      net=enrich$subnet
#  })


  res.obj<-list(network=net,enrichment=enrich.res,params=list(w=args$w,b=args$b,mu=args$mu),condition=condition)
                                        #dump to R
#  if(!is.null(args$output))
      saveRDS(res.obj,file=args$output)
                                        #writenetname
}

main()
