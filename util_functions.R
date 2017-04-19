get_option_list<-function(invalues){
  outValues<-unique(na.omit(invalues))
  outValues<-as.list(outValues)
  return(outValues)
}