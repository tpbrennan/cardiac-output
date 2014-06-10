
## CLEAR WORKSPACE
rm(list=ls())

## INPUT DATA
cohort = "sepsis";
path = c("/users/tombombadl/Dropbox/Research/Projects/Cardiac_Output")
csvfile = sprintf("%s/data/cardiac_output_%s.csv",path,cohort)
DATA = read.csv(csvfile)

#-------------------------------------------------------------------------
# Transform Categorical Variables
DATA$GENDER= factor(DATA$GENDER,labels=c("M","F"))
DATA$VSP_D1= factor(DATA$VSP_D1,labels=seq(0,max(DATA$VSP_D1)))
DATA$VSP_D2= factor(DATA$VSP_D2,labels=seq(0,max(DATA$VSP_D2)))
DATA$VSP_D3= factor(DATA$VSP_D3,labels=seq(0,max(DATA$VSP_D3)))
DATA$SD_D1= factor(DATA$SD_D1,labels=c("0","1"))
DATA$SD_D2= factor(DATA$SD_D2,labels=c("0","1"))
DATA$SD_D3= factor(DATA$SD_D3,labels=c("0","1"))
DATA$BB_D1= factor(DATA$BB_D1,labels=c("0","1"))
DATA$BB_D2= factor(DATA$BB_D2,labels=c("0","1"))
DATA$BB_D3= factor(DATA$BB_D3,labels=c("0","1"))
DATA$ETHNICITY = factor(DATA$ETHNICITY, labels=c("WHITE","BLACK","HISPANIC","ASIAN","OTHER"))
DATA$ICUMORT = factor(DATA$ICUMORT,labels=c("0","1"))
DATA$HOSPMORT= factor(DATA$HOSPMORT,labels=c("0","1"))
DATA$MORTALITY28D = factor(DATA$MORTALITY28D,labels=c("0","1"))
DATA$MORTALITY1YR = factor(DATA$MORTALITY1YR,labels=c("0","1"))
           
attach(DATA)

#-------------------------------------------------------------------------
# VARIABLES

vars_cnt = c("WEIGHT","AGE","ELIX28DPT","TCO2","CREATININE",
              "POTASSIUM","CHLORIDE","SODIUM","BUN","CALCIUM",
              "MAGNESIUM","WBC","LACTATE","ALT","AST",
              "SBP","DBP","HR","RR",
              "SPO2","TEMP","UO","PH","PAO2",
              "HEMOG")

vars_prop = c("GENDER","ETHNICITY","VSP","VNT","SD","BB")

vars_out = c("ICU_LOS","MORTALITY_28D",
             "MORTALITY_1Y","ICUSTAY_MORTALITY","HOSPITAL_MORTALITY")


#-------------------------------------------------------------------------
# Source function
source('/Users/tombombadl/Dropbox/Research/Projects/Cardiac_Output/R/cnt_analysis.R')
source('/Users/tombombadl/Dropbox/Research/Projects/Cardiac_Output/R/prop_analysis.R')

#-------------------------------------------------------------------------
day=c("D1","D2","D3")

for (d in seq(1,length(day))) {
  ff = file(sprintf("%s/Pubs/tex/%s_%s.tex",path,cohort,day[d]),open="at")
  
  q = quantile(eval(parse(text=paste("BPP",day,sep="_"))),na.rm=T)
  writeLines(sprintf("& [%s, %s) & [%s, %s) & [%s, %s) & [%s, %s] & Missing \\\\",
             q[1],q[2],q[2],q[3],q[3],q[4],q[4],q[5]),ff)
  
  writeLines("\\hline & \\multicolumn{4}{c}{\\textbf{N (\\%)}}\\\\ \\hline", ff)
  lapply(vars_prop,prop_analysis,day[d],ff)
  
  writeLines("\\hline & \\multicolumn{4}{c}{\\textbf{Median (IQR)}}\\\\ \\hline", ff)
  lapply(vars_cnt,cnt_analysis,day[d],ff)
  
  close(ff)
}

detach(DATA)