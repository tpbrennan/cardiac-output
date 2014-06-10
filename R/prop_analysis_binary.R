# FUNCTION - PROPORTIONAL binary ANALYSIS

prop_analysis_binary = function(var,day,thresh,ff) {
  
  y = eval(parse(text=paste("BPP",day,sep="_")))
  if ( var == 'GENDER' | var =='ETHNICITY' )  {
    x = eval(parse(text=var))
  } else if  ( var =='LVEF' ) {
    x = eval(parse(text=var))
    X = na.omit(cbind(x,y))
    x = factor(X[,1])
    y = X[,2]
  } else {
    x = eval(parse(text=paste(var,day,sep="_")))
  }
  ll = levels(x)
  
  # determine binary split
  z = as.numeric(y >= thresh)
  rsa = sprintf('%s & ~ & ~ & ~ \\\\',var)
  writeLines(rsa,ff)
  
  print(var)
  
  for ( j in seq(1,max(ll)) ) {
    
      # get data per level
      m=aggregate(y[x==ll[j]],list(z[x==ll[j]]),median,na.rm=T)
      s=by(y[x==ll[j]],list(z[x==ll[j]]),IQR,na.rm=T)
    
      rsa = sprintf(' %s&%.2f (%.2f)&%.2f (%.2f)',ll[j],m[1,2],iqr=s[1],m[1,2],iqr=s[2])

      # determine significance between groups
      tt = t.test(y[x==ll[j]] ~ z[x==ll[j]])
      if (tt$p.value<0.05) {
        rsa = paste(rsa,sprintf('\\textbf{p=%.4f*}\\\\',tt$p.value),sep='&')
      } else {
        rsa = paste(rsa,sprintf('p=%.4f\\\\',tt$p.value),sep='&')
      }
      writeLines(rsa,ff)
      
  }
}
