package org.example.engine;

public class ImpactResult {

    public String serviceName;

    // expected downtime contributed by dependent services only
    public double dependentServiceLoss;

    // downtime of the failed service itself
    public double selfDowntime;

    // λ × dependentServiceLoss
    public double expectedSystemImpact;

    // proportion of services affected
    public double affectedServiceRatio;

    public int affectedServiceCount;

    public ImpactResult(
            String serviceName,
            double dependentServiceLoss,
            double selfDowntime,
            double expectedSystemImpact,
            double affectedServiceRatio,
            int affectedServiceCount
    ) {
        this.serviceName = serviceName;
        this.dependentServiceLoss = dependentServiceLoss;
        this.selfDowntime = selfDowntime;
        this.expectedSystemImpact = expectedSystemImpact;
        this.affectedServiceRatio = affectedServiceRatio;
        this.affectedServiceCount = affectedServiceCount;
    }
}