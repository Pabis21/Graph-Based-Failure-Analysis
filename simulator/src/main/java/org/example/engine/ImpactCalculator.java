package org.example.engine;

import org.example.model.Edge;
import org.example.model.MicroserviceGraph;
import org.example.model.Service;

import java.util.*;

public class ImpactCalculator {

    private final MicroserviceGraph graph;

    public ImpactCalculator(MicroserviceGraph graph) {
        this.graph = graph;
    }

    public ImpactResult calculateImpact(Service source) {

        Map<Service, Double> probabilities = new HashMap<>();
        Queue<Service> queue = new LinkedList<>();

        probabilities.put(source, 1.0);
        queue.add(source);

        double dependentServiceLoss = 0.0;
        Set<Service> affectedServices = new HashSet<>();

        while (!queue.isEmpty()) {
            Service current = queue.poll();
            double currentProb = probabilities.get(current);

            for (Edge e : graph.getDependents(current)) {
                Service dependent = e.target;

                double newProb = currentProb * e.propagationProbability;

                // keep strongest discovered path to avoid overcounting
                if (!probabilities.containsKey(dependent) || newProb > probabilities.get(dependent)) {
                    probabilities.put(dependent, newProb);
                    queue.add(dependent);
                }
            }
        }

        for (Map.Entry<Service, Double> entry : probabilities.entrySet()) {
            Service affected = entry.getKey();

            if (!affected.equals(source)) {
                double pathProbability = entry.getValue();

                // expected downtime contribution of impacted dependent service
                dependentServiceLoss += pathProbability * affected.mttr;
                affectedServices.add(affected);
            }
        }

        double selfDowntime = source.mttr;

        // same research formula, just renamed for clarity
        double expectedSystemImpact = source.failureRate * dependentServiceLoss;

        double affectedServiceRatio =
                graph.services.size() <= 1 ? 0.0 :
                        (double) affectedServices.size() / (graph.services.size() - 1);

        return new ImpactResult(
                source.name,
                dependentServiceLoss,
                selfDowntime,
                expectedSystemImpact,
                affectedServiceRatio,
                affectedServices.size()
        );
    }

    public List<ImpactResult>  calculateAllImpacts() {
        List<ImpactResult> results = new ArrayList<>();

        for (Service s : graph.services) {
            results.add(calculateImpact(s));
        }

        return results;
    }

    public double calculateSVI(List<ImpactResult> results) {
        double sum = 0.0;
        for (ImpactResult r : results) {
            sum += r.expectedSystemImpact;
        }
        return sum;
    }

    public ImpactResult getMaxRiskService(List<ImpactResult> results) {
        ImpactResult max = results.get(0);

        for (ImpactResult r : results) {
            if (r.expectedSystemImpact > max.expectedSystemImpact) {
                max = r;
            }
        }

        return max;
    }
}