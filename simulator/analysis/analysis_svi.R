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

# Ensure consistent scenario order
all_data$scenario <- factor(
  all_data$scenario,
  levels = c("Baseline", "Low_P", "High_P", "High_MTTR", "High_Failure")
)

# -----------------------------
# Calculate SVI per scenario
# -----------------------------
svi_data <- all_data %>%
  group_by(scenario) %>%
  summarise(SVI = sum(expected), .groups = "drop")

print("System Vulnerability Index (SVI) by scenario:")
print(svi_data)

# -----------------------------
# Find max-risk service per scenario
# -----------------------------
max_risk <- all_data %>%
  group_by(scenario) %>%
  slice_max(order_by = expected, n = 1, with_ties = FALSE) %>%
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
ggsave("output/svi_comparison.png", plot = p1, width = 8, height = 5)

# -----------------------------
# Graph 2: Expected impact per service (all scenarios)
# -----------------------------
p2 <- ggplot(all_data, aes(x = service, y = expected, fill = scenario)) +
  geom_col(position = "dodge") +
  labs(
    title = "Expected Impact per Service Across Scenarios",
    x = "Service",
    y = "Expected Impact"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))

print(p2)
ggsave("output/expected_impact_by_service.png", plot = p2, width = 12, height = 6)

# -----------------------------
# Graph 3: Baseline raw vs expected impact
# -----------------------------
p_raw <- ggplot(baseline, aes(x = service, y = raw)) +
  geom_col() +
  labs(
    title = "Raw Impact per Service",
    x = "Service",
    y = "Raw Impact"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))

print(p_raw)
ggsave("output/raw_impact.png", plot = p_raw, width = 12, height = 6)

# -----------------------------
# Graph 4: Max-risk service per scenario
# -----------------------------
p4 <- ggplot(max_risk, aes(x = scenario, y = expected, fill = service)) +
  geom_col() +
  labs(
    title = "Max-Risk Service in Each Scenario",
    x = "Scenario",
    y = "Expected Impact"
  ) +
  theme_minimal()

print(p4)
ggsave("output/max_risk_service.png", plot = p4, width = 8, height = 5)