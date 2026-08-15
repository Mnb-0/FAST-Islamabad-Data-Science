# Clear workspace
rm(list = ls())

# (Data)
X <- c(2, 3, 4, 5, 6)
Y <- c(2.1, 2.5, 3.0, 3.3, 3.5)


plot(X, Y, main="Scatter Plot of Study Hours vs CGPA", 
     xlab="Study Hours", ylab="CGPA", pch=19, col="darkgreen")

model <- lm(Y ~ X)
summary(model)


plot(X, Y, main="Scatter Plot with Regression Line", 
     xlab="Study Hours", ylab="CGPA", pch=19, col="purple")
abline(model, col="blue", lwd=2)


correlation <- cor(X, Y)
cat("Correlation Coefficient (r):", correlation, "\n")

conf_intervals <- confint(model)
print(conf_intervals)


predicted_value <- predict(model, data.frame(X=7))
cat("Predicted CGPA for 7 hours of study:", predicted_value, "\n")


Y_hat <- predict(model)  # Predicted Y values
Y_mean <- mean(Y)

SSR <- sum((Y_hat - Y_mean)^2)   # Regression Sum of Squares
SSE <- sum((Y - Y_hat)^2)        # Error Sum of Squares
SST <- sum((Y - Y_mean)^2)       # Total Sum of Squares

cat("SSR (Regression Sum of Squares):", SSR, "\n")
cat("SSE (Error Sum of Squares):", SSE, "\n")
cat("SST (Total Sum of Squares):", SST, "\n")


R_squared <- SSR / SST
cat("R-squared (Coefficient of Determination):", R_squared, "\n")
# Interpretation: % of variation in CGPA explained by Study Hours.


anova_table <- anova(model)
print(anova_table)
