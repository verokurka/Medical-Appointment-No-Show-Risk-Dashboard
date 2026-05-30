# Purpose:

# Fit a baseline logistic regression model to explore which appointment and 
# patient characteristics are associated with no-show odds.


library(tidyverse)
library(broom)
library(rsample)
library(car)
library(yardstick)

# =========================
# Preparing the data sets
# =========================

noshow <- readRDS("data/processed/appointments_analysis_ready.rds")

noshow %>%
  count(age_group, sort = TRUE)

ns <- noshow %>%
  mutate(
    appointment_weekday = factor(as.character(appointment_weekday)),
    scheduled_weekday = factor(as.character(scheduled_weekday)),
    waiting_days_group = relevel(waiting_days_group, ref = "Same day"),
    age_group = relevel(age_group, ref = "50-64"),
    sms_status = relevel(as.factor(sms_status), ref = "No SMS received"),
    gender = relevel(as.factor(gender), ref = "F"),
    appointment_weekday = relevel(appointment_weekday, ref = "Monday"),
    scheduled_weekday = relevel(scheduled_weekday, ref = "Monday")
  )

set.seed(1802)

ns_split <- initial_split(
  ns, 
  prop = 0.8,
  strata = no_show_flag
)

ns_train <- training(ns_split)
ns_test <- testing(ns_split)

# =========================
# Modeling
# =========================

base_mod <- glm(no_show_flag ~ waiting_days_group + age_group + sms_status + 
                  gender + scholarship + hipertension + diabetes + alcoholism +
                  handicap_status + appointment_weekday + scheduled_weekday + 
                  neighbourhood,
                family = binomial,
                data = ns_train)

summary(base_mod)

# eliminating neighborhood because of its MANY levels, which makes it all messy
full_mod <- glm(no_show_flag ~ waiting_days_group + age_group + sms_status + 
                  gender + scholarship + hipertension + diabetes + alcoholism +
                  handicap_status + appointment_weekday + scheduled_weekday,
                family = binomial,
                data = ns_train)

summary(full_mod)

simp_mod <- glm(no_show_flag ~ waiting_days_group + age_group + sms_status + 
                  gender + scholarship + diabetes + alcoholism + handicap_status +
                  appointment_weekday + scheduled_weekday,
                family = binomial,
                data = ns_train)

AIC(full_mod, simp_mod) # keep simpler model
anova(simp_mod, full_mod, test = "Chisq") # either model works


null_mod <- glm(
  no_show_flag ~ 1,
  family = binomial,
  data = ns_train
)

AIC(null_mod, simp_mod)
anova(null_mod, simp_mod, test = "Chisq")
# my model is better than nothing!

# =========================
# Model diagnostic checks
# =========================

# convergence
simp_mod$converged

# multicollinearity
vif_results <- vif(simp_mod)
vif_results

vif_table <- as.data.frame(vif_results)

write_csv(
  as_tibble(vif_table, rownames = "term"),
  "outputs/tables/final_model_vif.csv"
)

# extreme coefficients
coef_check <- tidy(simp_mod) %>%
  arrange(desc(abs(estimate)))

coef_check

write_csv(
  coef_check,
  "outputs/tables/final_model_coefficient_check.csv"
)

# influential observations
mod_aug <- augment(simp_mod)

influence_summary <- mod_aug %>%
  summarise(
    max_cooks_distance = max(.cooksd, na.rm = TRUE),
    mean_cooks_distance = mean(.cooksd, na.rm = TRUE),
    n_high_cooks = sum(.cooksd > 4 / n(), na.rm = TRUE)
  ) # several observations exceeded the 4/n rule, but the treshold was very small

influence_summary

top_obs <- mod_aug %>%
  mutate(row_id = row_number()) %>%
  arrange(desc(.cooksd)) %>%
  select(
    row_id,
    .cooksd,
    .fitted,
    .resid,
    .hat,
    no_show_flag,
    waiting_days_group,
    age_group,
    sms_status,
    appointment_weekday,
    scheduled_weekday
  ) %>%
  slice_head(n = 10)

write_csv(
  influence_summary,
  "outputs/tables/final_model_influence_summary.csv"
)

write_csv(
  top_obs,
  "outputs/tables/final_model_top_influential_observations.csv"
)

# =========================
# Performance checks
# =========================

ns_pred <- ns_test %>%
  mutate(
    ns_prob = predict(
      simp_mod,
      newdata = ns_test,
      type = "response")
  )

summary(ns_pred$ns_prob) # nothing crazy, nothing bland

ns_pred %>%
  group_by(no_show_flag) %>%
  summarise(
    n = n(),
    mean_predicted_prob = mean(ns_prob),
    median_predicted_prob = median(ns_prob),
    min_predicted_prob = min(ns_prob),
    max_predicted_prob = max(ns_prob),
    .groups = "drop"
  )

ns_pred <- ns_pred %>%
  mutate(
    pred_class_050 = if_else(ns_prob >= 0.50, 1, 0)
  )

# confusion matrix
cm_50 <- ns_pred %>%
  count(no_show_flag, pred_class_050)

cm_50

# performance metrics
ns_pred_metrics <- ns_pred %>%
  mutate(
    actual_class = factor(no_show_flag, levels = c(1, 0)),
    pred_class_050 = factor(pred_class_050, levels = c(1, 0))
  )

classification_metrics_050 <- metric_set(
  accuracy,
  sens,
  spec,
  precision,
  f_meas
)(
  ns_pred_metrics,
  truth = actual_class,
  estimate = pred_class_050
)

classification_metrics_050 # trash results

threshold_results <- tibble(
  threshold = c(0.20, 0.25, 0.30, 0.35, 0.40, 0.50)
) %>%
  mutate(
    metrics = map(
      threshold,
      ~ ns_pred %>%
        mutate(
          pred_class = if_else(ns_prob >= .x, 1, 0),
          actual_class = factor(no_show_flag, levels = c(1, 0)),
          pred_class = factor(pred_class, levels = c(1, 0))
        ) %>%
        metric_set(
          accuracy,
          sens,
          spec,
          precision,
          f_meas
        )(
          truth = actual_class,
          estimate = pred_class
        )
    )
  ) %>%
  unnest(metrics)

threshold_results

threshold_results_wide <- threshold_results %>%
  select(threshold, .metric, .estimate) %>%
  pivot_wider(
    names_from = .metric,
    values_from = .estimate
  )

threshold_results_wide # 0.25 seems balanced

write_csv(
  threshold_results_wide,
  "outputs/tables/final_model_threshold_comparison.csv"
)

# re-do with 0.25
ns_pred <- ns_pred %>%
  mutate(
    pred_class_025 = if_else(ns_prob >= 0.25, 1, 0)
  )

# confusion matrix
confusion_matrix_025 <- ns_pred %>%
  count(no_show_flag, pred_class_025)

confusion_matrix_025

write_csv(
  confusion_matrix_025,
  "outputs/tables/final_model_confusion_matrix_threshold_025.csv"
)

ns_pred_metrics_025 <- ns_pred %>%
  mutate(
    actual_class = factor(no_show_flag, levels = c(1, 0)),
    pred_class_025 = factor(pred_class_025, levels = c(1, 0))
  )

classification_metrics_025 <- metric_set(
  accuracy,
  sens,
  spec,
  precision,
  f_meas
)(
  ns_pred_metrics_025,
  truth = actual_class,
  estimate = pred_class_025
)

classification_metrics_025

write_csv(
  classification_metrics_025,
  "outputs/tables/final_model_classification_metrics_threshold_025.csv"
)


# ROC - AUC
roc_auc_result <- roc_auc(
  ns_pred_metrics_025,
  truth = actual_class,
  ns_prob
)

roc_auc_result

write_csv(
  roc_auc_result,
  "outputs/tables/final_model_roc_auc.csv"
)

roc_curve_data <- roc_curve(
  ns_pred_metrics_025,
  truth = actual_class,
  ns_prob
)

roc_plot <- autoplot(roc_curve_data) +
  labs(
    title = "ROC Curve for Baseline Logistic Regression Model",
    subtitle = "Model performance evaluated on the held-out test set",
    x = "1 - Specificity",
    y = "Sensitivity"
  ) +
  theme_minimal()

roc_plot

ggsave(
  "outputs/charts/final_model_roc_curve.png",
  plot = roc_plot,
  width = 7,
  height = 5
)

# calibration table and plot

calibration_data <- ns_pred %>%
  mutate(
    risk_decile = ntile(ns_prob, 10)
  ) %>%
  group_by(risk_decile) %>%
  summarise(
    mean_predicted_prob = mean(ns_prob),
    observed_no_show_rate = mean(no_show_flag),
    total_appointments = n(),
    .groups = "drop"
  )

calibration_data

write_csv(
  calibration_data,
  "outputs/tables/final_model_calibration_table.csv"
)

calibration_plot <- ggplot(
  calibration_data,
  aes(x = mean_predicted_prob, y = observed_no_show_rate)
) +
  geom_point() +
  geom_line() +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(
    title = "Calibration Plot for Baseline Logistic Regression Model",
    subtitle = "Observed no-show rates compared with mean predicted probabilities by risk decile",
    x = "Mean predicted no-show probability",
    y = "Observed no-show rate"
  ) +
  scale_x_continuous(labels = scales::percent) +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal()

calibration_plot

ggsave(
  "outputs/charts/final_model_calibration_plot.png",
  plot = calibration_plot,
  width = 7,
  height = 5
)

# =========================
# Finalizing
# =========================

final_mod <- simp_mod

final_model_or <- tidy(
  final_mod,
  exponentiate = TRUE,
  conf.int = TRUE
)

final_model_or

final_model_or_clean <- final_model_or %>%
  filter(term != "(Intercept)") %>%
  mutate(
    odds_ratio = round(estimate, 2),
    conf.low = round(conf.low, 2),
    conf.high = round(conf.high, 2),
    ci_label = paste0(conf.low, "–", conf.high),
    p_value_label = case_when(
      p.value < 0.001 ~ "<0.001",
      TRUE ~ as.character(round(p.value, 3))
    )
  ) %>%
  select(
    term,
    odds_ratio,
    conf.low,
    conf.high,
    ci_label,
    p_value_label
  )
final_model_or_clean

write_csv(
  final_model_or_clean,
  "outputs/tables/final_logistic_model_odds_ratios_clean.csv"
)

final_model_or_main <- final_model_or_clean %>%
  filter(
    str_detect(
      term,
      "waiting_days_group|age_group|sms_status"
    )
  )

final_model_or_main

write_csv(
  final_model_or_main,
  "outputs/tables/final_logistic_model_odds_ratios_main.csv"
)

# odds ratio plot 
or_plot_data <- final_model_or_main %>%
  mutate(
    term_label = case_when(
      term == "waiting_days_group1 day" ~ "Waiting time: 1 day",
      term == "waiting_days_group2-3 days" ~ "Waiting time: 2–3 days",
      term == "waiting_days_group4-7 days" ~ "Waiting time: 4–7 days",
      term == "waiting_days_group8-14 days" ~ "Waiting time: 8–14 days",
      term == "waiting_days_group15-30 days" ~ "Waiting time: 15–30 days",
      term == "waiting_days_group31+ days" ~ "Waiting time: 31+ days",
      term == "age_groupChild" ~ "Age: Child",
      term == "age_groupTeen" ~ "Age: Teen",
      term == "age_group18-25" ~ "Age: 18–25",
      term == "age_group26-34" ~ "Age: 26–34",
      term == "age_group35-49" ~ "Age: 35–49",
      term == "age_group65+" ~ "Age: 65+",
      term == "sms_statusSMS received" ~ "SMS received",
      TRUE ~ term
    ),
    term_label = fct_reorder(term_label, odds_ratio)
  )

odds_ratio_plot <- ggplot(or_plot_data, aes(x = odds_ratio, y = term_label)) +
  geom_point() +
  geom_vline(xintercept = 1, linetype = "dashed") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high),
    width = 0.2
  ) +
  labs(
    title = "Adjusted Odds Ratios from Baseline Logistic Regression Model",
    subtitle = "Reference groups: same-day appointments, ages 50–64, and no SMS received",
    x = "Odds ratio",
    y = NULL
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold")
  )

odds_ratio_plot


ggsave(
  "outputs/charts/final_logistic_model_odds_ratio_plot.png",
  plot = odds_ratio_plot,
  width = 8,
  height = 6
)


# =========================
# Final model summary
# =========================

# The final baseline logistic regression model was fit on a training set containing
# 80% of the data.
# Predictors included waiting time group, age group, SMS status, gender,
# scholarship status, diabetes, alcoholism, handicap status, appointment weekday,
# and scheduled weekday.

# Diagnostics did not identify major model stability concerns:
# - Model converged successfully.
# - VIF/GVIF values did not indicate meaningful multicollinearity.
# - Cook's distance did not suggest that a single observation dominated the model.
# - Predicted probabilities ranged from low to moderate risk and were not extreme.

# Prediction performance was evaluated on the held-out test set.
# At a 0.25 classification threshold, the model identified about 67% of actual
# no-shows, with about 65% specificity and modest precision.
# ROC-AUC was approximately 0.73, suggesting decent discrimination for a baseline model.
# Calibration by risk decile showed predicted probabilities were reasonably aligned
# with observed no-show rates.
