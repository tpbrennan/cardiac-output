# FUNCTION cnt_analysis: binary analysis
cnt_analysis_binary = function(var,day,thresh,ff) {
  
  y = eval(parse(text=paste("BPP",day,sep="_")))
  if (var == "WEIGHT" | var == "AGE" | var == "ELIX28DPT") {
    x = eval(parse(text=var))
  } else {
    x = eval(parse(text=paste(var,day,sep="_")))
  }
  
  # remove NA
  X = na.omit(cbind(x,y))
  N = length(X)
  x = X[,1]
  y = X[,2]
  
  rsa = ''
  z = as.numeric(y >= thresh)
  
  m=aggregate(x,list(z),median,na.rm=T)
  s=by(x,list(z),IQR,na.rm=T)
  rsa = sprintf('%s&%.2f (%.2f)&%.2f (%.2f)',var,m[1,2],iqr=s[1],m[2,2],iqr=s[2])
    
  # student t-test
  tt = t.test(x~z)

  if (tt$p.value<0.05) {
    rsa = paste(rsa,sprintf('\\textbf{%.4f*}\\\\',tt$p.value),sep='&')
  } else {
    rsa = paste(rsa,sprintf('%.4f\\\\',tt$p.value),sep='&')
  }

  writeLines(rsa, ff)
  return()
}