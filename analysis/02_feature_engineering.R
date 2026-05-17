library(tidyverse)
library(lubridate)

noshow_features <- read_csv("data/processed/appointments_clean_base.csv")

glimpse(noshow_features)
summary(noshow_features)

# bucketing waiting days
noshow_features <- noshow_features %>%
  mutate(waiting_days_group = case_when(
    waiting_days == 0 ~ "Same day",
    waiting_days == 1 ~ "1 day",
    waiting_days <= 3 ~ "2-3 days",
    waiting_days <= 7 ~ "4-7 days",
    waiting_days <= 14 ~ "8-14 days",
    waiting_days <= 30 ~ "15-30 days",
    waiting_days > 30 ~ "31+ days",
    TRUE ~ NA_character_)
  )

noshow_features %>%
  count(waiting_days_group)

# bucketing age
noshow_features <- noshow_features %>%
  mutate(age_group = case_when(
    age  <= 12 ~ "Child",
    age <= 17 ~ "Teen",
    age <= 25 ~ "18-25",
    age <= 34 ~ "26-34",
    age <= 49 ~ "35-49",
    age <= 64 ~ "50-64",
    age >= 65 ~ "65+",
    TRUE ~ NA_character_
    )
  )

noshow_features %>%
  count(age_group)


# extracting weekday
noshow_features <- noshow_features %>%
  mutate(
    appointment_weekday = wday(
      appointment_date,
      label = TRUE,
      abbr = FALSE,
      week_start = 1
    )
  )

noshow_features %>%
  count(appointment_weekday)

noshow_features <- noshow_features %>%
  mutate(
    scheduled_weekday = wday(
      scheduled_date,
      label = TRUE,
      abbr = FALSE,
      week_start = 1
    )
  )

noshow_features %>%
  count(scheduled_weekday)

# rating chronic conditions
noshow_features <- noshow_features %>%
  mutate(
    chronic_condition_count = hipertension + diabetes + alcoholism + handicap_status
  )

noshow_features %>%
  count(chronic_condition_count)

# creating dashboard friendly labels for binaries
noshow_features <- noshow_features %>%
  mutate(
    sms_status = case_when(
      sms_received == 1 ~ "SMS received",
      sms_received == 0 ~ "No SMS received",
      TRUE ~ NA_character_),
    scholarship_status = case_when(
      scholarship == 1 ~ "Scholarship",
      scholarship == 0 ~ "No scholarship",
      TRUE ~ NA_character_),
    hypertension_status = case_when(
      hipertension == 1 ~ "Hypertension recorded",
      hipertension == 0 ~ "No hypertension recorded",
      TRUE ~ NA_character_),
    diabetes_status = case_when(
      diabetes == 1 ~ "Diabetes recorded",
      diabetes == 0 ~ "No diabetes recorded",
      TRUE ~ NA_character_ ),
    alcoholism_status = case_when(
      alcoholism == 1 ~ "Alcoholism recorded",
      alcoholism == 0 ~ "No alcoholism recorded",
      TRUE ~ NA_character_),
    handicap_status_label = case_when(
      handicap_status == 1 ~ "Handicap recorded",
      handicap_status == 0 ~ "No handicap recorded",
      TRUE ~ NA_character_),
    no_show_status = case_when(
      no_show_flag == 1 ~ "No-show",
      no_show_flag == 0 ~ "Showed up",
      TRUE ~ NA_character_)
  )

write_csv(noshow_features, "data/processed/appointments_analysis_ready.csv")


