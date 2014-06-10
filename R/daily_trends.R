## LIBRARIES 
library(rattle)
library(Hmisc)
library(fBasics)
library(gplots)
library(vcd)
library(ellipse)
library(rpart)
library(ROCR)
library(party)
library(ada)
library(colorspace)
library(randomForest)
library(e1071)
library(doParallel)
library(kernlab)
library(texreg)
library(epicalc)
library(prettyR)
library(xtable)


## CLEAR WORKSPACE
rm(list=ls())

## INPUT DATA
filename = c("data/cardiac_output_sepsis_final.csv")
path = c("/users/tombombadl/Dropbox/Research/Projects/Cardiac_Output/")
DATA = read.csv(paste(path,filename,sep=""))

# Transform Categorical Variables
DATA$GENDER= factor(DATA$GENDER,labels=c("M","F"))
DATA$VSPD1= factor(DATA$VSPD1,labels=seq(0,max(DATA$VSPD1)))
DATA$VSPD2= factor(DATA$VSPD2,labels=seq(0,max(DATA$VSPD2)))
DATA$VSPD3= factor(DATA$VSPD3,labels=seq(0,max(DATA$VSPD3)))
DATA$SDD1= factor(DATA$SDD1,labels=c("0","1"))
DATA$SDD2= factor(DATA$SDD2,labels=c("0","1"))
DATA$SDD3= factor(DATA$SDD3,labels=c("0","1"))
DATA$BBD1= factor(DATA$BBD1,labels=c("0","1"))
DATA$BBD2= factor(DATA$BBD2,labels=c("0","1"))
DATA$BBD3= factor(DATA$BBD3,labels=c("0","1"))
DATA$ETHNICITY = factor(DATA$ETHNICITY, labels=c("WHITE","BLACK","HISPANIC","ASIAN","OTHER"))
DATA$ICUSTAY_MORTALITY= factor(DATA$ICUSTAY_MORTALITY,labels=c("0","1"))
DATA$HOSPITAL_MORTALITY= factor(DATA$HOSPITAL_MORTALITY,labels=c("0","1"))
DATA$MORTALITY_28D= factor(DATA$MORTALITY_28D,labels=c("0","1"))
DATA$MORTALITY_1YR= factor(DATA$MORTALITY_1YR,labels=c("0","1"))
           

summary(DATA)

attach(DATA)

#-------------------------------------------------------------------------
# UNIVARIATE ANALYSIS
vars_cnt = c("SBPMD1","SBPSD1","SBPMD2","SBPSD2","SBPMD3",          
             "SBPSD3","DBPMD1","DBPSD1","DBPMD2",            
             "DBPSD2","DBPMD3","DBPSD3","MBPMD1",            
             "MBPSD1","MBPMD2","MBPSD2","MBPMD3",           
             "MBPSD3","PPMD1","PPSD1","PPMD2",             
             "PPSD2","PPMD3","PPSD3","HRMD1"             
             "HRSD1","HRMD2","HRSD2","HRMD3"             
             "HRSD3","LMD1","LSD1","LMD2"              
             "LSD2","LMD3","LSD3","UOD1"              
             "UOD2","UOD3")

vars = c("SBPM","SBPS","DBPM","DBPS","MBPM","MBPS","PPM","PPS","HRM","HRS","LM","LS","UO")

vars_cat = c("GENDER","CAREUNIT","ICD9_GROUP")
vars_prop = c("CM_DIABETES","CM_ALCOHOL_ABUSE","CM_ARRHYTHMIAS",
              "CM_VALVULAR_DISEASE","CM_HYPERTENSION","CM_RENAL_FAILURE",
              "CM_CHRONIC_PULMONARY","CM_LIVER_DISEASE","CM_CANCER","CM_PSYCHOSIS",   
              "CM_DEPRESSION","CM_CHF","RRT","VASOPRESSOR","VENTILATED")
vars_out = c("ICU_LOS","HOSP_LOS","MORTALITY_28D",
             "ONE_YEAR_MORTALITY","ICUSTAY_MORTALITY","HOSPITAL_MORTALITY")

#-------------------------------------------------------------------------
# MELT DATA
mbxplot = function(var) {
  ff = paste(path,"plots/bxplt_",var,".pdf",sep="")
  x = melt(DATA[c(paste(var,"D1",sep=""),
                  paste(var,"D2",sep=""),
                  paste(var,"D3",sep=""),
                  "MORTALITY_28D", id.var="MORTALITY_28D")])
  p=ggplot(data = x, aes(x=variable, y=value)) + geom_boxplot(aes(fill=MORTALITY_28D))
  ggsave(ff, plot=p)
}

lapply(vars,mbxplot)

#-------------------------------------------------------------------------
# BOXPLOT
bxplot = function(var) {
  ff = paste(path,"plots/bxplt_",var,".pdf",sep="")
  x = eval(parse(text=paste(var,"~MORTALITY_28D",sep="")))
  p = boxplot(x,xlab="28-day Mortality",ylab=var,col="grey90",breaks="fd",border=TRUE)

}

#-------------------------------------------------------------------------
# Table 1: Univariate Summary ~ HYPERDYNAMIC


# FUNCTION - SIGNIFICANCE TESTING NUMERICS
cnt_analysis= function(var) {
  x = eval(parse(text=var))
  m = aggregate(DATA[var],DATA["HYPERDYNAMIC"],mean,na.rm=T)
  s = aggregate(DATA[var],DATA["HYPERDYNAMIC"],sd,na.rm=T)
  tt = t.test(eval(parse(text=paste(var,"~HYPERDYNAMIC",sep=""))))
  cbind(mean=m[2],std.dev=s[2],P=round(tt$p.value,3))
}

uniprop_analysis = function(var) {
  x = eval(parse(text=var))
  tn = table(x,HYPERDYNAMIC)
  p = prop.table(tn)
  cbind(N0=t[,1],sprintf("(%1.2f%%)", 100*p[,1]),N1=t[,2],sprintf("(%1.2f%%)", 100*p[,2]))
}

m = t(aggregate(DATA[vars_cnt],DATA["HYPERDYNAMIC"],mean,na.rm=T))
s = t(aggregate(DATA[vars_cnt],DATA["HYPERDYNAMIC"],sd,na.rm=T))

aggregate(DATA[vars_cnt],DATA["HYPERDYNAMIC"],brkdn,na.rm=T)
brkdn(x,DATA)
tt = t.test(x,paired=F,data=DATA)

cbind(mean=m[,1],std.dev=s[,1],mean=m[,2],std.dev=m[,2])

n = by(DATA[vars_prop],DATA["HYPERDYNAMIC"],summary)
s = t(aggregate(DATA[vars_cnt],DATA["HYPERDYNAMIC"],sd,na.rm=T)
cbind(mean=m[,1],std.dev=s[,1],mean=m[,2],std.dev=m[,2])



      
              
#-------------------------------------------------------------------------
# CUMMULATIVE SURVIVAL PLOTS
breaks = seq(0,365,by=5)
survivors = DATA$SURVIVAL_DAYS
survivors.cut = cut(survivors, breaks, right=FALSE)
survivors.freq = table(survivors.cut)
cumfq = c(0, cumsum(survivors.freq)/sum(survivors.freq))
plot(breaks,cumfq, xlab="Days",ylab="% Deaths")

#-------------------------------------------------------------------------

# FUNCTION - HISTOGRAM  
hplot= function(var) {
  #pdf(paste(path,"density_",var,".pdf",sep=""))
  x = eval(parse(text=var))
  hs = hist(x,ylab="Frequency",main="",xlab=var,
            col="grey90",breaks="fd",border=TRUE)
  dens = density(x)
  rs = max(hs$counts)/max(dens$y)
  lines(dens$x,dens$y*rs, type="l",col=rainbow_hcl(1)[1])
  #rug(x)
  title(main=paste("Distribution of",var))
  #dev.off()
}

# DEFINE FUNCTION - BARPLOT
bplot= function(var) {
  #pdf(paste(path,"barplot_",var,".pdf",sep=""))
  x = eval(parse(text=var))
  ds = summary(x)
  bp = barplot(ds,ylab="Frequency",xlab=var,ylim=c(0,max(ds+max(ds)*0.1)))
  text(bp,ds+max(ds)*0.05,paste(ds," (",round(100*ds/sum(ds)),"%)",sep=""))
}



# SIGNIFICANCE TESTING - PROP.test(AGE ~ GENDER,paired=F,data=DATA)
panal= function(var) {
  x = eval(parse(text=var))
  tbl = table(x,GENDER)
  summary(tbl)
  pt = prop.test(tbl, correct=F)  
}

#-------------------------------------------------------------------------

# DEFINE NUMERICS & CATEGORICALS
numerics = c("WEIGHT","AGE")
props = c("CAREUNIT")

#-------------------------------------------------------------------------

# STATISTICAL ANALYSIS
lapply(paste(numerics,"~GENDER",sep=""),nanal)
lapply(numerics,hplot)
lapply(props,bplot)
lapply(props,panal)

#-------------------------------------------------------------------------

# CORRELATION
corr = cor(DATA[,numerics],)
cols = ifelse(corr>0, rgb(0,0,abs(corr)), rgb(abs(corr),0,0))
plotcorr(corr,col=cols)

#-------------------------------------------------------------------------

# LOGISTIC REGRESSION
mylogit= glm(MORTALITY_FLG_1YR ~ AGE + WEIGHT + SAPS + ELIX_PT + 
                 GENDER + CAREUNIT + MARITAL_STATUS + ETHNICITY,data=DATA,family="binomial")
# Coefficients of Logistic Regression
summary(mylogit)
# Odds Ration and Confidence Intervals
exp(cbind(OR = coef(mylogit),confint(mylogit)))
# LaTeX
texreg(list(mylogit))
# Plot ROC
auc = lroc(mylogit,title=FALSE,auc.coords = c(.3,.1))


# TODO - DETERMINE AUC

