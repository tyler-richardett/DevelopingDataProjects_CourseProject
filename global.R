housing <- read.csv("kc_house_data.csv")
housing <- housing[-15871, c(3:8, 11:12, 15, 17)]
housing$zipcode <- as.factor(housing$zipcode)