# dependency_network.R

library(igraph)

cat("Loading dependency data...\n")

deps <- read.csv(
  "D:/MSC main project/codes/simulator/src/main/resources/dependencies_baseline.csv",
  stringsAsFactors = FALSE
)

print(deps)

if (ncol(deps) < 2) {
  stop("CSV must contain at least 2 columns for dependencies.")
}

colnames(deps)[1:2] <- c("source", "target")
deps <- deps[, c("source", "target")]

deps <- deps[
  !is.na(deps$source) & !is.na(deps$target) &
    deps$source != "" & deps$target != "",
]

cat("Cleaned dependency data:\n")
print(deps)

g <- graph_from_data_frame(deps, directed = TRUE)

services <- V(g)$name
cat("Services in dependency graph:\n")
print(services)

V(g)$color <- ifelse(
  V(g)$name == "api_gateway", "#FF6B6B",
  ifelse(
    V(g)$name %in% c("data_storage", "cache_service"), "#74C476",
    ifelse(
      V(g)$name %in% c("message_queue", "payment_gateway"), "#FDAE6B",
      "#6BAED6"
    )
  )
)

V(g)$size <- ifelse(V(g)$name == "api_gateway", 50, 35)

lay <- layout_with_sugiyama(g)$layout

png("dependency_graph_layered.png", width = 1400, height = 1000)

plot(
  g,
  layout = lay,
  vertex.frame.color = "black",
  vertex.label.color = "black",
  vertex.label.cex = 1.0,
  vertex.label.family = "sans",
  edge.arrow.size = 0.4,
  edge.width = 1.8,
  edge.color = "gray40",
  edge.curved = 0.1,
  margin = 0.2,
  main = "Layered Microservice Dependency Architecture"
)

dev.off()

cat("Dependency graph saved as dependency_graph_layered.png\n")