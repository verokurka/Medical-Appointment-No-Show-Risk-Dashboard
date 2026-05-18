library(tidyverse)
library(scales)

noshow <- readRDS("data/processed/appointments_analysis_ready.rds")

# =========================
# SUMMARY TABLES
# =========================


# overall no shows
overall_summary <- noshow %>%
  summarise(
    total_appointments = n(),
    total_no_shows = sum(no_show_flag),
    no_show_rate = mean(no_show_flag),
    no_show_percent = mean(no_show_flag) * 100
  )

overall_summary
write_csv(overall_summary, "outputs/tables/overall_summary.csv")

# summarizing by age group
nsb_age_group <- noshow %>%
  group_by(age_group) %>%
  summarise(
    total_appointments = n(),
    total_no_shows = sum(no_show_flag),
    no_show_rate = mean(no_show_flag),
    no_show_percent = mean(no_show_flag) * 100,
    .groups = "drop"
  ) 

nsb_age_group
write_csv(nsb_age_group, "outputs/tables/no_show_by_age_group.csv")

# summarizing by waiting days
nsb_waiting_days_group <- noshow %>%
  group_by(waiting_days_group) %>%
  summarise(
    total_appointments = n(),
    total_no_shows = sum(no_show_flag),
    no_show_rate = mean(no_show_flag),
    no_show_percent = mean(no_show_flag) * 100,
    .groups = "drop"
  ) 

nsb_waiting_days_group
write_csv(nsb_waiting_days_group, "outputs/tables/no_show_by_waiting_days_group.csv")


# summarizing by week day
nsb_appointment_weekday <- noshow %>%
  group_by(appointment_weekday) %>%
  summarise(
    total_appointments = n(),
    total_no_shows = sum(no_show_flag),
    no_show_rate = mean(no_show_flag),
    no_show_percent = mean(no_show_flag) * 100,
    .groups = "drop"
  )

nsb_appointment_weekday
write_csv(nsb_appointment_weekday, "outputs/tables/no_show_by_appointment_weekday.csv")

nsb_scheduled_weekday <- noshow %>%
  group_by(scheduled_weekday) %>%
  summarise(
    total_appointments = n(),
    total_no_shows = sum(no_show_flag),
    no_show_rate = mean(no_show_flag),
    no_show_percent = mean(no_show_flag) * 100,
    .groups = "drop"
  )

nsb_scheduled_weekday
write_csv(nsb_scheduled_weekday, "outputs/tables/no_show_by_scheduled_weekday.csv")

# summarizing by SMS status
nsb_sms <- noshow %>%
  group_by(sms_status) %>%
  summarise(
    total_appointments = n(),
    total_no_shows = sum(no_show_flag),
    no_show_rate = mean(no_show_flag),
    no_show_percent = mean(no_show_flag) * 100,
    .groups = "drop"
  )

nsb_sms
write_csv(nsb_sms, "outputs/tables/no_show_by_sms_status.csv")

# summarizing by gender
nsb_gender <- noshow %>%
  group_by(gender) %>%
  summarise(
    total_appointments = n(),
    total_no_shows = sum(no_show_flag),
    no_show_rate = mean(no_show_flag),
    no_show_percent = mean(no_show_flag) * 100,
    .groups = "drop"
  )

nsb_gender
write_csv(nsb_gender, "outputs/tables/no_show_by_gender.csv")

# summarizing by neighbourhood
nsb_neighbourhood <- noshow %>%
  group_by(neighbourhood) %>%
  summarise(
    total_appointments = n(),
    total_no_shows = sum(no_show_flag),
    no_show_rate = mean(no_show_flag),
    no_show_percent = mean(no_show_flag) * 100,
    .groups = "drop"
  ) %>%
  arrange(desc(no_show_percent))

nsb_neighbourhood
write_csv(nsb_neighbourhood, "outputs/tables/no_show_by_neighbourhood.csv")

# keeping only neighbourhoods with >100 appts
nsb_neighbourhood_min100 <- nsb_neighbourhood %>%
  filter(total_appointments >= 100) %>%
  arrange(desc(no_show_percent))

nsb_neighbourhood_min100
write_csv(nsb_neighbourhood_min100, "outputs/tables/no_show_by_neighbourhood_min100.csv")

# =========================
# CHARTS!
# =========================

# age group
age_group_plot <- ggplot(nsb_age_group,
  aes(x = age_group, y = no_show_percent)) +
  geom_col() +
  labs(
    title = "No-Show Percentage by Age Group",
    subtitle = "Medical appointment no-show rates varied across age groups",
    x = "Age group",
    y = "No-show percentage"
  ) +
  scale_y_continuous(
    labels = scales::label_percent(scale = 1)
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

age_group_plot

ggsave(
  filename = "outputs/charts/no_show_by_age_group.png",
  plot = age_group_plot,
  width = 8,
  height = 5
)

# waiting days group
waiting_days_plot <- ggplot(
  nsb_waiting_days_group,
  aes(x = waiting_days_group, y = no_show_percent)
) +
  geom_col() +
  labs(
    title = "No-Show Percentage by Waiting Time",
    subtitle = "No-show rates varied by time between scheduling and appointment",
    x = "Waiting time between scheduling and appointment",
    y = "No-show percentage"
  ) +
  scale_y_continuous(
    labels = scales::label_percent(scale = 1)
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

waiting_days_plot

ggsave(
  filename = "outputs/charts/no_show_by_waiting_days_group.png",
  plot = waiting_days_plot,
  width = 8,
  height = 5
)

# appointment weekday
appointment_weekday_plot <- ggplot(
  nsb_appointment_weekday,
  aes(x = appointment_weekday, y = no_show_percent)
) +
  geom_col() +
  labs(
    title = "No-Show Percentage by Appointment Weekday",
    subtitle = "No-show rates compared by the day the appointment occurred",
    x = "Appointment weekday",
    y = "No-show percentage"
  ) +
  scale_y_continuous(
    labels = scales::label_percent(scale = 1)
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"))
  

appointment_weekday_plot

ggsave(
  filename = "outputs/charts/no_show_by_appointment_weekday.png",
  plot = appointment_weekday_plot,
  width = 8,
  height = 5
)

# scheduled weekday
scheduled_weekday_plot <- ggplot(
  nsb_scheduled_weekday,
  aes(x = scheduled_weekday, y = no_show_percent)
) +
  geom_col() +
  labs(
    title = "No-Show Percentage by Scheduled Weekday",
    subtitle = "No-show rates compared by the day the appointment was scheduled",
    x = "Scheduled weekday",
    y = "No-show percentage"
  ) +
  scale_y_continuous(
    labels = scales::label_percent(scale = 1)
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold")
  )

scheduled_weekday_plot

ggsave(
  filename = "outputs/charts/no_show_by_scheduled_weekday.png",
  plot = scheduled_weekday_plot,
  width = 8,
  height = 5
)

# SMS status
sms_plot <- ggplot(
  nsb_sms,
  aes(x = sms_status, y = no_show_percent)
) +
  geom_col() +
  labs(
    title = "No-Show Percentage by SMS Reminder Status",
    subtitle = "No-show rates compared by whether an SMS reminder was recorded",
    x = "SMS reminder status",
    y = "No-show percentage"
  ) +
  scale_y_continuous(
    labels = scales::label_percent(scale = 1)
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold")
  )

sms_plot

ggsave(
  filename = "outputs/charts/no_show_by_sms_status.png",
  plot = sms_plot,
  width = 8,
  height = 5
)


# gender
gender_plot <- ggplot(
  nsb_gender,
  aes(x = recode(gender, "F" = "Female", "M" = "Male"), y = no_show_percent)
) +
  geom_col() +
  labs(
    title = "No-Show Percentage by Gender",
    subtitle = "No-show rates compared by recorded patient gender",
    x = "Gender",
    y = "No-show percentage"
  ) +
  scale_y_continuous(
    labels = scales::label_percent(scale = 1)
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold")
  )

gender_plot

ggsave(
  filename = "outputs/charts/no_show_by_gender.png",
  plot = gender_plot,
  width = 8,
  height = 5
)

# neighbourhoods (with >100 appts)
neigh_min100_top15 <- nsb_neighbourhood_min100 %>%
  slice_max(no_show_percent, n = 15)

neigh_min100_top15_plot <- ggplot(
  neigh_min100_top15,
  aes(x = reorder(neighbourhood, no_show_percent), y = no_show_percent)
) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 15 Neighbourhoods by No-Show Percentage",
    subtitle = "Limited to neighbourhoods with at least 100 appointments",
    x = "Neighbourhood",
    y = "No-show percentage"
  ) +
  scale_y_continuous(
    labels = scales::label_percent(scale = 1)
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold")
  )

neigh_min100_top15_plot 
ggsave(
  filename = "outputs/charts/no_show_by_neighbourhood_min100_top15.png",
  plot = neigh_min100_top15_plot ,
  width = 9,
  height = 6
)


# =========================
# Preliminary findings
# =========================

# Interpretation notes based on these outputs are documented in case_study_notes.md.