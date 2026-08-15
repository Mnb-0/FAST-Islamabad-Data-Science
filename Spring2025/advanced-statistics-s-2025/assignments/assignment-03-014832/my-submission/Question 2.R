# Load necessary packages
library(ggplot2)
library(GGally)
library(car)

# (Data)
Y <- c(2.1, 2.5, 3.0, 3.3, 3.5)
X1 <- c(2, 3, 4, 5, 6)
X2 <- c(10, 8, 5, 3, 2)

data <- data.frame(Y, X1, X2)


ggpairs(data, upper = list(continuous = wrap("points")), diag = list(continuous = "blank"))



cor_matrix <- cor(data)
print("Correlation Matrix:")
print(cor_matrix)


model <- lm(Y ~ X1 + X2, data = data)
summary(model)


vcov_matrix <- vcov(model)
print("Variance-Covariance Matrix:")
print(vcov_matrix)


confint(model)


new_data <- data.frame(X1 = 1, X2 = 4)
predict(model, newdata = new_data, interval = "confidence")


Y_hat <- predict(model)
Y_mean <- mean(Y)
SSR <- sum((Y_hat - Y_mean)^2)
SSE <- sum((Y - Y_hat)^2)
SST <- sum((Y - Y_mean)^2)

cat("SSR (Regression):", SSR, "\n")
cat("SSE (Error):", SSE, "\n")
cat("SST (Total):", SST, "\n")


r_squared <- summary(model)$r.squared
cat("R-squared:", r_squared, "\n")




anova(model)