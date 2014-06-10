# FUNCTION - PROPORTIONAL QUARTILE ANALYSIS
prop_analysis= function(var,day,ff) {
  
  y = eval(parse(text=paste("BPP",day,sep="_")))
  if ( var == 'GENDER' | var =='ETHNICITY') 
    x = eval(parse(text=var))
  else
    x = eval(parse(text=paste(var,day,sep="_")))
  
  qrts = quantile(y,na.rm=T)
  ll = levels(x)
  
  for ( j in seq(1,length(ll)) ) {
    
    if ( var == 'GENDER' | var =='ETHNICITY') {
      rsa = ''
      for ( i in seq(2,5) ) {
        flg = as.numeric(y > qrts[i-1] & y < qrts[i],na.rm=T)
        
        tn = table(x,flg)
        p = prop.table(tn)
        
        if (i==2) {
          rsa = sprintf('%s&%d (%.1f)',ll[j],tn[j,2],p[j,2]*100)
        } else {
          rsa = paste(rsa,sprintf('%d (%.1f)',tn[j,2],p[j,2]*100),sep="&")
        }
      }
      rsa = paste(rsa,"\\\\",sep="")
      writeLines(rsa,ff)
    } else if ( var =="VSP" ) {
      rsa = ''
      for ( i in seq(2,5) ) {
        flg = as.numeric(y > qrts[i-1] & y < qrts[i],na.rm=T)
        
        tn = table(x,flg)
        p = prop.table(tn)
        
        if (i==2) {
          rsa = sprintf('%sx VSP&%d (%.1f)',ll[j],tn[j,2],p[j,2]*100)
        } else {
          rsa = paste(rsa,sprintf('%d (%.1f)',tn[j,2],p[j,2]*100),sep="&")
        }
      }
      rsa = paste(rsa,"\\\\",sep="")
      writeLines(rsa,ff)
    } else {
      rsa = ''
      for ( i in seq(2,5) ) {
        flg = as.numeric(y > qrts[i-1] & y < qrts[i],na.rm=T)
        
        tn = table(x,flg)
        p = prop.table(tn)
        
        if (i==2) {
          rsa = sprintf('%s&%d (%.1f)',var,tn[j+1,2],p[j+1,2]*100)
        } else {
          rsa = paste(rsa,sprintf('%d (%.1f)',tn[j+1,2],p[j+1,2]*100),sep="&")
        }
      }
      rsa = paste(rsa,"\\\\",sep="")
      writeLines(rsa,ff)
      return();
    }
  }
}
#qrt_prop_analysis("GENDER","D1")