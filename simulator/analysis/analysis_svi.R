library(ggplot2)
library(dplyr)
library(readr)

# -----------------------------
# Load scenario CSV files
# -----------------------------
baseline <- read_csv("../../output/impact_baseline.csv", show_col_types = FALSE)
low_p <- read_csv("../../output/impact_low_p.csv", show_col_types = FALSE)
high_p <- read_csv("../../output/impact_high_p.csv", show_col_types = FALSE)
high_mttr <- read_csv("../../output/impact_high_mttr.csv", show_col_types = FALSE)
high_failure <- read_csv("../../output/impact_high_failure.csv", show_col_types = FALSE)

# -----------------------------
# Add scenario labels
# -----------------------------
baseline$scenario <- "Baseline"
low_p$scenario <- "Low_P"
high_p$scenario <- "High_P"
high_mttr$scenario <- "High_MTTR"
high_failure$scenario <- "High_Failure"

# -----------------------------
# Combine all results
# -----------------------------
all_data <- bind_rows(
  baseline,
  low_p,
  high_p,
  high_mttr,
  high_failure
)

all_data$scenario <- factor(
  all_data$scenario,
  levels = c("Baseline", "Low_P", "High_P", "High_MTTR", "High_Failure")
)

# -----------------------------
# Calculate SVI per scenario
# -----------------------------
svi_data <- all_data %>%
  group_by(scenario) %>%
  summarise(SVI = sum(expected_system_impact), .groups = "drop")

print("System Vulnerability Index (SVI) by scenario:")
print(svi_data)

# -----------------------------
# Find max-risk service per scenario
# -----------------------------
max_risk <- all_data %>%
  group_by(scenario) %>%
  slice_max(order_by = expected_system_impact, n = 1, with_ties = FALSE) %>%
  ungroup()

print("Max-risk service by scenario:")
print(max_risk)

# -----------------------------
# Graph 1: SVI comparison
# -----------------------------
p1 <- ggplot(svi_data, aes(x = scenario, y = SVI, fill = scenario)) +
  geom_col() +
  labs(
    title = "System Vulnerability Index Across Scenarios",
    x = "Scenario",
    y = "SVI"
  ) +
  theme_minimal()

print(p1)
ggsave("../../output/svi_comparison.png", plot = p1, width = 8, height = 5)

# -----------------------------
# Graph 2: Expected system impact per service across scenarios
# -----------------------------
p2 <- ggplot(all_data, aes(x = service, y = expected_system_impact, fill = scenario)) +
  geom_col(position = "dodge") +
  labs(
    title = "Expected System Impact per Service Across Scenarios",
    x = "Service",
    y = "Expected System Impact"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))

print(p2)
ggsave("../../output/expected_system_impact_by_service.png", plot = p2, width = 12, height = 6)

# -----------------------------
# Graph 3: Dependent service loss per service (baseline)
# -----------------------------
p3 <- ggplot(baseline, aes(x = service, y = dependent_service_loss)) +
  geom_col() +
  labs(
    title = "Dependent Service Loss per Service (Baseline)",
    x = "Service",
    y = "Dependent Service Loss"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))

print(p3)
ggsave("../../output/dependent_service_loss_baseline.png", plot = p3, width = 12, height = 6)

# -----------------------------
# Graph 4: Affected service ratio per service (baseline)
# -----------------------------
p4 <- ggplot(baseline, aes(x = service, y = affected_service_ratio)) +
  geom_col() +
  labs(
    title = "Affected Service Ratio per Service (Baseline)",
    x = "Service",
    y = "Affected Service Ratio"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))

print(p4)
ggsave("../../output/affected_service_ratio_baseline.png", plot = p4, width = 12, height = 6)

# -----------------------------
# Graph 5: Max-risk service per scenario
# -----------------------------
p5 <- ggplot(max_risk, aes(x = scenario, y = expected_system_impact, fill = service)) +
  geom_col() +
  labs(
    title = "Max-Risk Service in Each Scenario",
    x = "Scenario",
    y = "Expected System Impact"
  ) +
  theme_minimal()

print(p5)
ggsave("../../output/max_risk_service.png", plot = p5, width = 8, height = 5)