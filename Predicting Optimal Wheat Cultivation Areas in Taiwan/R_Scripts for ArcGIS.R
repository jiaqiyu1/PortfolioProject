#packages
install.packages("tidyr")
library("tidyr")
install.packages('dplyr')
library(dplyr)
install.packages('lubridate')
library(lubridate)

setwd("~/Desktop/阿龜/codis data")
C0F9P0<-read.csv("codis_C0F9P0.csv",header = T)
df<-as.data.frame(C0F9P0)
df$log_time<-as.POSIXct(df$log_time)


#dataframe過濾的方法，df[{過濾row的條件}, {過濾column的條件}]
#{過濾column的條件}如果留白就會是全部column都取
#Functions "POSIXlt" and "POSIXct" representing calendar dates and times.

# 取出特定月份的方法 1月至4月??——> 但是出現TRUE而已
format(as.POSIXct(df3$log_time), "%m") %in% c("01",  "02",  "03",  "04")

#2016-2018資料處理
df2<-subset.data.frame(df,log_time >= "2016-01-01" )
df3<-subset.data.frame(df2,log_time < "2019-01-01" )
df4<-subset.data.frame(df3,format(as.POSIXct(df3$log_time), "%m") %in% c("01",  "02",  "03",  "04"))

#meantemp
meantemp<- summarise(group_by(df4,
                                     hour = floor_date(as.POSIXct(log_time), # 要做統計的欄位，以這次的例子就是時間
                                      unit='days')), # 時間要取到小時 e.g. 2點5分 -> 2點
                                      average_temperature = mean(as.numeric(as.character(air_temperature)))) # 統計值，在此為要取到這小時的平均

#去除NA值
newmeantemp2<-na.omit(meantemp)
#is.na用于判断向量内的元素是否为NA，返回结果
newmeantemp<-meantemp[!is.na(meantemp$average_temperature), ]
#兩個方法是一樣的結果

#round_date()=四舍五入取整,floor_date()=向下取整,ceiling_date()=向上取整

#mice package模擬補全缺失, 參照https://rpubs.com/skydome20/R-Note10-Missing_Value
#mean=numeric	Unconditional mean imputation
install.packages("mice")
library(mice)

#code
mice.meantemp <- mice(meantemp,
                      m = 1,           # 產生1個被填補好的資料表
                      maxit = 10000,      # max iteration
                      method = "mean", # 使用mean，進行遺漏值預測，method有很多都可更改
                      seed = 188)      # set.seed()，令抽樣每次都一樣
#補齊缺失
newmeantemp<-complete(mice.meantemp, 1)
#檢測有沒有NA值
complete.cases(newmeantemp)

#一星期的中位數
#mediantemp_week
mediantemp<- summarise(group_by(newmeantemp,
                                week = floor_date(as.POSIXct(hour),
                                                  unit='week')), 
                       median_temperature = median(as.numeric(as.character(average_temperature)))) 

#溫度分級迴圈
mediantemp_c<-mediantemp$median_temperature
#matrix to input data，1=no of column
outAll_temp=matrix(NA,length(mediantemp_c),1)

#mediantemp[1]
#[1] 19.7375
#所以把meantemp套進i裡面，然後把meantemp的第[1:42]寫進去


  for (i in 1:length(mediantemp_c)) {
    outAll_temp[i,1]=
     if(mediantemp_c[i]>= 21.0 & mediantemp_c[i]<= 22.0){
        print("6")
        }else if(mediantemp_c[i]>= 22.0 & mediantemp_c[i]<= 22.9){
          print("5")
          }else if(mediantemp_c[i]>= 20.0 & mediantemp_c[i]<= 20.9){
              print("5")
          }else if(mediantemp_c[i]>= 18.0 & mediantemp_c[i]<= 19.9){
            print("4")
          }else if(mediantemp_c[i]>= 23.0 & mediantemp_c[i]<= 24.9){
            print("4")
          }else if(mediantemp_c[i]>= 25.0 & mediantemp_c[i]<= 26.9){
            print("3")
          }else if(mediantemp_c[i]>= 16.0 & mediantemp_c[i]<= 17.9){
            print("3")
          }else if(mediantemp_c[i]>= 27.0 & mediantemp_c[i]<= 29.9){
            print("2")
          }else if(mediantemp_c[i]>= 13.0 & mediantemp_c[i]<= 15.9){
            print("2")
          }else if(mediantemp_c[i]>= 30.0 & mediantemp_c[i]<= 31.9){
            print("1")
          }else if(mediantemp_c[i]>= 10.0 & mediantemp_c[i]<= 11.9){
            print("1")
            }else{
                print("0")
       }
   }


#meanhumidity
meanhumid<- summarise(group_by(df4,
                                  hour = floor_date(as.POSIXct(log_time), 
                                                    unit='days')), 
                         average_humidity = mean(as.numeric(as.character(air_humidity)))) 

mice.meanhumid <- mice(meanhumid,
                          m = 1,          
                          maxit = 10000,     
                          method = "mean",
                          seed = 188) 
newmeanhumid<-complete(mice.meanhumid, 1)
#medianhumidity_week
medianhumid<- summarise(group_by(newmeanhumid,
                                    week = round_date(as.POSIXct(hour),
                                                      unit='week')), 
                           median_humidity = median(as.numeric(as.character(average_humidity)))) 
#濕度分級迴圈
medianhumid_c<-medianhumid$median_humidity
#matrix to input data，1=no of column
outAll_humid<-matrix(NA,length(medianhumid_c),1)

for (j in 1:length(medianhumid_c)) {
  outAll_humid[j,1]=
    if(medianhumid_c[j] >= 86.0 & medianhumid_c[j] <= 88.0){
      print("6")
    }else if(medianhumid_c[j] >= 70.0 & medianhumid_c[j] < 86.0){
      print("4")
    }else if(medianhumid_c[j] >= 60.0 & medianhumid_c[j] < 70.0){
      print("2")
    }else if(medianhumid_c[j] > 88.0 & medianhumid_c[j] < 60.0){
      print("0")
    }else{
      print("0")
    }
}

##把資料串連
summary_out<-cbind(mediantemp,medianhumid$median_humidity,outAll_temp,outAll_humid)

##千粒重_相對值總分計算
temp1<-as.numeric(as.character(summary_out$outAll_temp))
humid1<-as.numeric(as.character(summary_out$outAll_humid))
千粒重_相對值<-0

for (a in 1:length(temp1)) {
  千粒重_相對值[a]<-abs(temp1[a]*-0.7+humid1[a]*-5)
 print(千粒重_相對值[a])
 }  

千粒重_相對值判斷<-matrix(NA,length(千粒重_相對值),1)
for(b in 1:length(千粒重_相對值)) {
  outAll_千粒重_相對值判斷[b,1]=
  if(千粒重_相對值[b] <= 10.0){
    print("四等")
  }else if(千粒重_相對值[b] > 10.0 & 千粒重_相對值[b] < 20.0){
    print("三等")
  }else if(千粒重_相對值[b] >= 20.0 & 千粒重_相對值[b]< 29.9){
    print("二等")
  }else{
    print("一等")
  }
}

##降落值_相對值總分計算 （取絕對值） 
降落值_相對值<-0
for (a in 1:length(temp1)) {
  降落值_相對值[a]<-temp1[a]*4.3+humid1[a]*-5
  print(降落值_相對值[a])
} 

##降落值和千粒重加總

千粒降落_加總<-0
for (a in 1:length(temp1)) {
  千粒降落_加總[a]<-千粒重_相對值[a]+降落值_相對值[a]
  print(千粒降落_加總[a])
}

  
##千粒重計算

千粒重<-0
for (a in 1:length(temp1)) {
  千粒重[a]<-190.4749-2.3994*temp1[a]-1.3624*humid1[a]
  print(千粒重[a])
} 

##降落值(取絕對值)
降落值<-0
for (a in 1:length(temp1)) {
  降落值[a]<-abs(496.6065+11.6971*temp1[a]+3.1727*humid1[a])
  print(降落值[a])
} 

outAll_降落值<-matrix(NA,length(降落值),1)
for(b in 1:length(降落值)) {
  outAll_降落值[b,1]=
    if(降落值[b] >= 300.0){
      print("健康，發芽良好")
    }else{
      print("發芽劣勢")
    }
}

##資料串連
summary_out2<-as.data.frame(cbind(mediantemp,medianhumid$median_humidity,outAll_temp,outAll_humid,降落值_相對值,千粒重_相對值,千粒重_相對值判斷,千粒降落_加總,千粒重,降落值,outAll_降落值))
summary(summary_out2)
##輸出資料
write.csv(summary_out2,file="C0F9P0.csv")
write.csv(summary(summary_out2),file="C0F9P0_summary.csv")



