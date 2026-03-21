package org.example;

import org.example.engine.*;
import org.example.model.MicroserviceGraph;

import java.util.List;

public class Main {

    static class Scenario {
        String name;
        String servicesFile;
        String dependenciesFile;
        String outputFile;

        Scenario(String name, String servicesFile, String dependenciesFile, String outputFile) {
            this.name = name;
            this.servicesFile = servicesFile;
            this.dependenciesFile = dependenciesFile;
            this.outputFile = outputFile;
        }
    }

    public static void main(String[] args) throws Exception {

        Scenario[] scenarios = new Scenario[] {
                new Scenario("Baseline", "services_baseline.csv", "dependencies_baseline.csv", "output/impact_baseline.csv"),
                new Scenario("Low Probability", "services_baseline.csv", "dependencies_low_p.csv", "output/impact_low_p.csv"),
                new Scenario("High Probability", "services_baseline.csv", "dependencies_high_p.csv", "output/impact_high_p.csv"),
                new Scenario("High MTTR", "services_high_mttr.csv", "dependencies_baseline.csv", "output/impact_high_mttr.csv"),
                new Scenario("High Failure Rate", "services_high_failure.csv", "dependencies_baseline.csv", "output/impact_high_failure.csv")
        };

        for (Scenario scenario : scenarios) {
            System.out.println("\n==============================");
            System.out.println("Running scenario: " + scenario.name);
            System.out.println("==============================");

            MicroserviceGraph graph = new MicroserviceGraph();

            CSVLoader.loadServices(scenario.servicesFile, graph);
            CSVLoader.loadDependencies(scenario.dependenciesFile, graph);

            ImpactCalculator calculator = new ImpactCalculator(graph);
            List<ImpactResult> results = calculator.calculateAllImpacts();

            ExportImpactResults.export(results, scenario.outputFile);

            double svi = calculator.calculateSVI(results);
            ImpactResult max = calculator.getMaxRiskService(results);

            System.out.println("\n--- SYSTEM IMPACT RESULTS (" + scenario.name + ") ---");
            for (ImpactResult r : results) {
                System.out.println(
                        r.serviceName +
                                " | Dependent Loss: " + r.dependentServiceLoss +
                                " | Self Downtime: " + r.selfDowntime +
                                " | Expected System Impact: " + r.expectedSystemImpact +
                                " | Affected Ratio: " + r.affectedServiceRatio +
                                " | Affected Count: " + r.affectedServiceCount
                );
            }

            System.out.println("\nSystem Vulnerability Index (SVI): " + svi);
            System.out.println("Max Risk Service: " + max.serviceName + " (" + max.expectedSystemImpact + ")");
        }

        System.out.println("\nAll scenarios completed.");
    }
}