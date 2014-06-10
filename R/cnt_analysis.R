cnt_analysis= function(var,day,ff) {
  
  y = eval(parse(text=paste("BPP",day,sep="_")))
  if (var == "WEIGHT" | var == "AGE" | var == "ELIX28DPT")
    x = eval(parse(text=var))
  else
    x = eval(parse(text=paste(var,day,sep="_")))
  qrts = quantile(y,na.rm=T)
  
  rsa = ''
  for (i in seq(2,5)) {
    flg = as.numeric(y > qrts[i-1] & y < qrts[i],na.rm=T)
    
    m=aggregate(x,list(flg),median,na.rm=T)
    s=by(x,list(flg),IQR,na.rm=T)
    
    if (i==2) {
      rsa = sprintf('%s&%.2f (%.2f)',var,m[2,2],iqr=s[2])
    } else {
      rsa = paste(rsa,sprintf('%.2f (%.2f)',m[2,2],iqr=s[2]),sep="&")
    }
  }
  
  # linear regression analysis
  mylm = lm(x~y)
  pval = summary(mylm)$coefficients[2,4]
  coeff = summary(mylm)$coefficients[2,1]
  if (pval<0.05)
    rsa = paste(rsa,sprintf('\\textbf{%.4f*}\\\\',coeff),sep='&')
  else
    rsa = paste(rsa,sprintf('%.4f\\\\',coeff),sep='&')
  writeLines(rsa, ff)
  return()
}