# FUNCTION: Continuous variable analysis over specified quartile (default quintile)
cnt_analysis_quartile= function(var,day,ff,qrts) {
  
  y = eval(parse(text=paste("BPP",day,sep="_")))
  if (var == "WEIGHT" | var == "AGE" | var == "ELIX28DPT") {
    x = eval(parse(text=var))
  } else {
    x = eval(parse(text=paste(var,day,sep="_")))
  }
  
  if (missing(qrts))
      qrts = quantile(y,na.rm=T)
  
  rsa = ''
  for (i in seq(2,5)) {
    flg = as.numeric(y > qrts[i-1] & y < qrts[i],na.rm=T)
    m=aggregate(x,list(flg),median,na.rm=T)
    s=by(x,list(flg),IQR,na.rm=T)
    
    if (i==2) {
      rsa = sprintf('%s&%.2f (%.2f)',var,m[2,2],iqr=s[2])
      cat = flg;
    } else {
      rsa = paste(rsa,sprintf('%.2f (%.2f)',m[2,2],iqr=s[2]),sep="&")
      cat[flg==1] = i-1
    }
  }
  ctf = factor(cat,labels=c("1","2","3","4","NA"))
  
  # linear regression analysis
  a = anova(lm(x~ctf))
  if (a["Pr(>F)"][1,1]<0.05) {
    rsa = paste(rsa,sprintf('\\textbf{%.4f*}\\\\',a["F value"][1,1]),sep='&')
  } else {
    rsa = paste(rsa,sprintf('%.4f\\\\',a["F value"][1,1]),sep='&')
  }
  
  writeLines(rsa, ff)
  return()
}