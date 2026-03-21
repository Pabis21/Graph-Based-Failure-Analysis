package org.example.engine;

import java.io.File;
import java.io.PrintWriter;
import java.util.List;

public class ExportImpactResults {

    public static void export(List<ImpactResult> results, String fileName) throws Exception {
        File outFile = new File(fileName);
        File parent = outFile.getParentFile();

        if (parent != null && !parent.exists()) {
            parent.mkdirs();
        }

        PrintWriter writer = new PrintWriter(outFile);

        writer.println("service,dependent_service_loss,self_downtime,expected_system_impact,affected_service_ratio,affected_service_count");

        for (ImpactResult r : results) {
            writer.println(
                    r.serviceName + "," +
                            r.dependentServiceLoss + "," +
                            r.selfDowntime + "," +
                            r.expectedSystemImpact + "," +
                            r.affectedServiceRatio + "," +
                            r.affectedServiceCount
            );
        }

        writer.close();
    }
}