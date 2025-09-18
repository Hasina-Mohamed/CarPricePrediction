# Car Price Prediction – End-to-End ML (R)

**Author:** Hasina Mohamed Ahmed  
**Keywords:** regression, feature engineering, XGBoost, deployment, Shiny

## Overview
I built a system that predicts used-car prices using information such as **year**, **mileage**, **engine size**, **fuel type**, **transmission**, and **weight**.  
The project follows a complete ML workflow: **data cleaning → feature engineering → EDA → model training → comparison → deployment**.

- **Dataset:** 2,230 vehicles, 32 features  
- **Best model:** XGBoost (captured non-linear interactions)  
- **Demo:** [Live Shiny App](<live-link>)  
- **Slides/Poster (optional):** <poster-or-slides-link>

## Why it matters (plain language)
Accurate pricing helps with **fair listings**, **trade-ins**, and **insurance valuation**. This project shows how data and ML can support everyday decisions in automotive markets.

## Methods (short + clear)
- **Cleaning:** fixed encodings, standardized numeric fields, handled missing values, trimmed outliers, removed duplicates.  
- **Features:** vehicle **age (2025 − year)**, **annual mileage**, **log(price)**, **price per mile**, and harmonized categories.  
- **Models compared:** Linear Regression, **Ridge**, **LASSO**, **Random Forest**, **XGBoost**.  
- **Evaluation:** RMSE and R² on a held-out test set (70/30 split, fixed seed).

> Tip for non-technical readers: **Lower RMSE** and **higher R²** mean better predictions.

## Results (example format)
| Model            | RMSE | R²   |
|------------------|-----:|:----:|
| Linear Regression| 4849 | 0.71 |
| Ridge            | 1768 | 0.85 |
| LASSO            | 1332 | 0.88 |
| Random Forest    |  550 | 0.95 |
| **XGBoost**      | **150** | **0.99** |

*(Numbers are placeholders—update with your actual run; the Rmd prints them.)*

**Key drivers:** newer year, lower mileage, larger engine size, automatic transmission.  
**Takeaway:** modern ensemble methods (XGBoost) gave the best accuracy.

## Repo Structure
