#### OBJECTIVE

# For an Auto-Insurance Company, predict the Customer Life-Time Value (CLV)

#### Directory Set-up ####

getwd()
Directory <- "C:/Users/ASHUTOSH DAS/Desktop/IVY - Final Project"
setwd(Directory)

#### Pre-Processing ####

df <- read.csv('Fn-UseC_-Marketing-Customer-Value-Analysis.csv')

df1 = df # Backing-up the original data

View(df1)

#### Library Installations/ re-calling ####

library(corrplot)
library(ggplot2)
library(dplyr)
library(caTools)
library(car)
library(lmtest)
library(nortest)
library(Metrics)
library(ggpubr)
library(tidyr)
library(carData)

#### Data Preparation ####

str(df1)
summary(df1)
nrow(df1)    # 9134 rows

df1$Effective.To.Date <- as.Date(df1$Effective.To.Date, "%m/%d/%y")
df1$Customer <- as.character(df1$Customer)
str(df1)

# Customer .Lifetime.value is the dependent variable for this analysis

#Determination and Removal/Imputation of Missing Values

any(is.na(df1)) 

# Any duplicated data

length(apply(df1, 1, function(x) unique(x))) # The number of rows returned is equal to the nrow of the dataframe. Hence, no duplicated value present.

#### Exploratory Data Analysis ####

hist(df1$Customer.Lifetime.Value, main="Histogram for Customer Lifetime Value", xlab = "Customer Lifetime Value")
mean(df1$Customer.Lifetime.Value)     # 8004.94
median(df1$Customer.Lifetime.Value)   # 5780.182
# As mean >> median, it can be said that the data is positively skewed.

hist(df1$Monthly.Premium.Auto, main="Histogram for Monthly Premium Auto", xlab = "Monthly Premium Auto")
mean(df1$Monthly.Premium.Auto)     # 93.21
median(df1$Monthly.Premium.Auto)   # 83
#As mean > median, it can be said that the data is positively skewed.

hist(MCV$Total.Claim.Amount, main="Histogram for Total Claim Amount", xlab = "Total Claim Auto")
mean(df1$Total.Claim.Amount)     # 434.08
median(df1$Total.Claim.Amount)   # 383.94
#As mean > median, it can be said that the data is positively skewed.

#### Hypothesis Creation and Validation ####
#### 1 Customers from Rural Location Code are valued LESS than customers from Urban Location Code 

hcv_1 <- df1[,c("Location.Code", "Customer.Lifetime.Value")] %>% subset(Location.Code == "Urban" | Location.Code == "Rural")
wilcox.test(Customer.Lifetime.Value~Location.Code, data=hcv_1, alternative="less")
# Based from the test result's p-value, the difference in distributions for rural and urban in terms of Customer Value Lifetime is not significant.

hcv_2 <- df1[,c("Location.Code", "Total.Claim.Amount")] %>% subset(Location.Code == "Urban" | Location.Code == "Rural")
wilcox.test(Total.Claim.Amount~Location.Code, data=hcv_2, alternative="less")
# Rural customers are less valuable in terms of claim amount.

hcv_3 <- df1[,c("Location.Code", "Monthly.Premium.Auto")] %>% subset(Location.Code == "Urban" | Location.Code == "Rural")
wilcox.test(Monthly.Premium.Auto~Location.Code, data=hcv_3, alternative="less")
# The difference between the distributions of rural and urban customers are not significant in terms of monthly premium auto.

#### 2 Customers with Education level of Bachelors or equivalent degree are more valuable than others

hcv_4 <- df1[,c("Education", "Customer.Lifetime.Value")]
kruskal.test(Customer.Lifetime.Value~Education, data=hcv_4)
# Since the two variables are not related to each other, we are using kruskal-Walls test.,
# As p<0.05, the hypotheis is true.

####  Outlier Determination and Treatment  ####

quantile(df1$Customer.Lifetime.Value,c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,0.99,0.995,1))
boxplot(df1$Customer.Lifetime.Value)

df2 = df1[df1$Customer.Lifetime.Value <20000,] #Creating a new data frame with a cap on outlier of clv for 20K
boxplot(df2$Customer.Lifetime.Value)

df3 = df2[df2$Customer.Lifetime.Value <15000,] #Creating another new data frame with a cap on outlier of clv for 15K
boxplot(df3$Customer.Lifetime.Value)

df4 = df3[df3$Customer.Lifetime.Value <14410,] #Creating another new data frame with a cap on outlier of clv for 14.4K
boxplot(df4$Customer.Lifetime.Value)
nrow(df4)           # 8089

#Number of Rows removed because of the outliers is 1045, which is 11 % of the original data
nrow(df1) - nrow(df4)
(nrow(df1) - nrow(df4))/nrow(df1)

quantile(df4$Income,c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,0.99,0.995,1))
boxplot(df1$Income)   # No Outlier

quantile(df4$Monthly.Premium.Auto,c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,0.99,0.995,1))
boxplot(df4$Monthly.Premium.Auto)   

df5 = df4[df4$Monthly.Premium.Auto <150,]
boxplot(df5$Monthly.Premium.Auto)

#Number of Rows removed because of the outliers is 1333, which is 14.6 % of the original data

nrow(df1) - nrow(df5)
(nrow(df1) - nrow(df5))/nrow(df1)

# Dropping Redundant Variable
df6=select(df5,-c(Customer,Effective.To.Date))
str(df6)

#### Data-set Splitting ####

set.seed(123)
sample <- sample.split(df5$Customer.Lifetime.Value,SplitRatio = 0.7)
df6.train <- subset(df6,sample == TRUE)
df6.test <- subset(df6,sample == FALSE)

nrow(df6.train) # Number of Rows is 5460
nrow(df6.test)  # Number of Rows is 2341

#### Model Training and Validation  ####

#Iteration 0
train.model1 <- lm(Customer.Lifetime.Value ~ .,data = df6.train)         # R-Squared is 28.66 %
summary(train.model1)
par(mfrow=c(2,2))
plot(train.model1)

#Iteration 1
train.model2 <- lm(Customer.Lifetime.Value ~  Monthly.Premium.Auto+ I(Renew.Offer.Type == 'Offer2')+ I(Renew.Offer.Type == 'Offer3')+ I(Renew.Offer.Type == 'Offer4')+ Number.of.Policies+ Number.of.Open.Complaints+ Months.Since.Policy.Inception,data = df6.train)      # R-Squared is 27.09 %
summary(train.model2)
par(mfrow=c(2,2))
plot(train.model2)

#### Model Testing  ####

final.model<- lm(Customer.Lifetime.Value ~  Monthly.Premium.Auto+ I(Renew.Offer.Type == 'Offer2')+ I(Renew.Offer.Type == 'Offer3')+ I(Renew.Offer.Type == 'Offer4')+ Number.of.Policies+ Number.of.Open.Complaints+ Months.Since.Policy.Inception,data = df6.test)
Customer.Lifetime.Value.predictions <- predict(final.model,df6.test)
results <- cbind(Customer.Lifetime.Value.predictions,df6.test$Customer.Lifetime.Value)
colnames(results) <- c('predicted', 'actual')
results <- as.data.frame(results)
resids <- final.model$residuals

#### Assumption Diagnostics ####

ad.test(resids) # Anderson-Darling Test for Normality . 
                # The p-value is lower than 0.05, therefore the errors are NOT normally distributed.
qqnorm(resids)


vif(final.model)   # Test for Multi-Collinearity
# Preferred to have value lower than 3.
# There is no presence of Multi-Collinearity.

bptest(final.model) # Breusch-Pagan Test to test for Homoscedacity
# p>0.05 preferred
# Fails the test

ncvTest(final.model) #Cook-Weisberg Test
                      # Passes and Proves Homoscedacity # p = 0.06 > 0.05

durbinWatsonTest(final.model) # Durbin - Watson Test
                              # Fails

#### Errors ####

mse <- mean((results$actual - results$predicted))^2
rmse <- mse ^0.5
print(rmse)    # 1.06e-11

SSE <- sum((results$predicted - results$actual)^2) #Sum of Squared Errors
SST <- sum((mean(df6$Customer.Lifetime.Value) - results$actual)^2) #Sum of Squared Totals
R.Squared <- 1- SSE/SST
print(R.Squared)        # 26.37 %
mape(results$actual,results$predicted) # 0.36


