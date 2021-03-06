#!/usr/bin/env Rscript

suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(dten))
require(methods)

getArgs<-function(){

  option_list <- list(
    make_option(c("-i", "--input"), dest='input',help='Comma-delimited list of tab-delimited file of expression values in tidied format with the following column names: counts,gene,sample,conditions'),
    make_option(c("-o", "--output"), default="testprots.tsv", dest='output',help = "Prefix to add to output files"),
    make_option(c('-d','--idtype'),default='entrez',dest='idtype',help='Type of gene identifier'),
    make_option(c('-c','--condition'),dest='condition',default=NULL,help='Comma-delimited list of condition of interest to find differentially regulated proteins')
  )

  args=parse_args(OptionParser(option_list = option_list))

  return(args)
}

main<-function(){
  args<-getArgs()
  if(args$input=="")
    tab<-system.file('glioma_dataset.csv',package='dten')
  else
    tab<-args$input

  ext <- rev(unlist(strsplit(basename(tab),split='.',fixed=T)))[1]

  if(length(grep('csv',ext))>0)
	  sep=','
  else
	  sep='\t'
  tidied.df<-unique(read.table(tab,sep=sep,header=T))

  req.names=c('counts','gene','sample','conditions')

  #check names
  mn<-setdiff(req.names,names(tidied.df))
  if(length(mn)>0){
    print(paste("Data frame does not have required header:",paste(mn,collapse=',')))

    print('Requires file name, id-type (entrez or hugo), and condition of interest as input')

  }

  cond=args$condition
  if(is.null(cond))
      cond<-setdiff(unique(tidied.df$conditions),c(NA,"","Other","Ganglioglioma","Ependymoma"))
  print(cond)
  lapply(cond,function(co){
      res<-dten::getProteinsFromGenesCondition(tidied.df,co,args$idtype)
      res$condition=rep(co,nrow(res))
      write.table(res,file=paste(gsub(' ','',co),args$output,sep=''),sep='\t',quote=F,row.names=F)

  })


}

main()
