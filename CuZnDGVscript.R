#######################################################################
#######################################################################
#
#              ********  Cu and Zn draft DGV adjuster  *********    
#
#######################################################################
#######################################################################
# Jenni Gadd and Caroline Fraser
# NIWA and LWP Ltd
# Created: September 2023
#

## Set up directory files --------------------
## You need to have Burrlioz loaded on your computer for this R script to work
load(file="C:\\Program Files (x86)\\CSIRO\\Burrlioz 2.0\\Burrlioz\\Rtemp\\.Rdata")   # change the folder as needed
ZnGVDir = ""  ## Set the directory where you have saved this R script & the Rdata files
## ZnGVDir = "C:\\Gaddjb_files\\ZnDGVfiles\\"  example

# Load in Burrlioz and set default values ####################
rm(a, fit1, new.fit1, zztest, old.fit, read.csv, writelabels, trial.data, PictureBox2.ImageLocation,
   trim, trim.leading, trim.trailing)  ## just getting rid of bits we don't need
## Bits needed for getting the Burrlioz plot function to work - need for fitted line (colour, etc)
linecol="black";plot95protect=FALSE;xdefault=T;reflevel=F;options(scipen=6)
#######################################################################
## Libraries and data files needed
library(plyr)  ## Required
library(tidyverse)  ## Required
# Read coefficients and species data ###########
load(file = paste0(ZnGVDir,"ZnMLRcoeffs.Rdata"))
load(file = paste0(ZnGVDir,"zn.toxdf.Rdata"))
######################################################################
# Functions --------------
GetZnGuidelines <- function(sens = zn.species.data, tMLR = MLR.coeffs, input, Zncol){
  
  #Don't calculate if any of the observations are out of the fitting bounds
  if(input$DOC>15|input$pH<6.2|input$H>440){
    #GV<-data.frame(PC99=NA,PC95=NA,PC90=NA,PC80=NA)
    Note<-"Data out of range, conservative estimate used"
  }else{
    
    if(input$DOC<0.5|input$pH>8.3|input$H<20){
      Note<-"Data out of range, GV may not be sufficiently protective"
    }else{
      Note<-"Data in range, GV suitable"
    }
  }
  myDOC <- min(max(input$DOC, 0.5), 15)
  myH   <- min(max(input$H, 20), 440)
  mypH  <- min(max(input$pH, 6.2), 8.3)
  
  tMLR[is.na(tMLR)]<-0  #Zero out coefficients that are NA - will mean that these parts of the general full
  #Equation below do not contribute to the formula
  sens<-merge(sens,tMLR,by.x="Model used",by.y="type")
  #Apply generic equation form
  sens$AdjECx <- exp(sens$Sensitivity + sens$DOC*log(input$DOC) + sens$H*log(input$H)+
                       sens$pH*input$pH + sens$DOC.pH*log(input$DOC)*input$pH)
  
  #Fit Burr function and extract protection values
  res <- try(fit(sens$AdjECx),silent = FALSE)
  if(isTRUE(class(res)=="try-error")) { # if data cannot be fitted, NA is recorded
    GV<-data.frame(ZnPC99=NA,ZnPC95=NA,ZnPC90=NA,ZnPC80=NA) 
  }  else { 
    GV = as.data.frame(t(quantile(res,c(0.01,0.05,0.1,0.2))))
    names(GV)<-c("ZnPC99", "ZnPC95", "ZnPC90", "ZnPC80")  
    GV <- cbind(GV, Note) 
  } 
  GV$Provisional_BioZnConc <- input[,Zncol]*4.1/GV$ZnPC95
  input<-cbind(input,GV)
  return(input)
}

####################
GetCuGuidelines <- function(input, Cucol){
  #Apply equation form
  GVs<-data.frame(CuPC99=NA,CuPC95=NA,CuPC90=NA,CuPC80=NA) 
  GVs$CuPC99 <- max(0.2, 0.20* (input$DOC/0.5)^0.977)
  GVs$CuPC95 <- max(0.47, 0.47* (input$DOC/0.5)^0.977)
  GVs$CuPC90 <- max(0.73, 0.73* (input$DOC/0.5)^0.977)
  GVs$CuPC80 <- max(1.3, 1.3* (input$DOC/0.5)^0.977)
  GVs$CuBioF <- 0.47/GVs$CuPC95
  GVs$BioCuConc <- input[,Cucol]*GVs$CuBioF
  input<-cbind(input,GVs)
  return(input)
}

#######################################
# Example to use functions using ddply
example.input <- data.frame(row = c(1,2,3, 4, 5, 6, 7), DOC = c(0.5, 0.5, 0.5, 1, 1.5, 2, 15), 
                         H = c(30, 60, 90, 30, 30, 30, 30), pH = c(7.5, 7.5, 7.5, 7.5, 7.5, 7.5, 7.5),
                         Cu_ugL = c(1, 0.5, 0.6, 0.8, 1.5, 3.2, 3.8))

Zn.output<-ddply(example.input,.(row),function(x) GetZnGuidelines(input=x))

Cu.output<-ddply(Zn.output,.(row),function(x) GetCuGuidelines(input=x, Cucol = "Cu_ugL"))

#############################################
## input your csv file with the tmf data and then run as follows
mydata <- read.csv("whereever my file is")

Zn.output<-ddply(mydata,.(row),function(x) GetZnGuidelines(input=x))  ## This adds the Zn DGVs to your data file
Cu.output<-ddply(Zn.output,.(row),function(x) GetZCuuidelines(input=x, Cucol = "Cu_ugL"))  ## This adds the Cu DGVs to the same file
