package org.example.engine;

import org.example.model.MicroserviceGraph;
import org.example.model.Service;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

public class CSVLoader {

    public static void loadServices(String fileName, MicroserviceGraph graph) throws Exception {

        InputStream input = CSVLoader.class
                .getClassLoader()
                .getResourceAsStream(fileName);

        BufferedReader br = new BufferedReader(new InputStreamReader(input));

        String line;
        br.readLine();

        while ((line = br.readLine()) != null) {

            String[] parts = line.split(",");

            String name = parts[0];
            double failureRate = Double.parseDouble(parts[1]);
            int mttr = Integer.parseInt(parts[2]);

            Service service = new Service(name, failureRate, mttr);
            graph.addService(service);


        }

        br.close();
    }

    public static void loadDependencies(String fileName, MicroserviceGraph graph) throws Exception {

        InputStream input = CSVLoader.class
                .getClassLoader()
                .getResourceAsStream(fileName);

        BufferedReader br = new BufferedReader(new InputStreamReader(input));

        String line;
        br.readLine();

        while ((line = br.readLine()) != null) {

            String[] parts = line.split(",");

            String source = parts[0];
            String target = parts[1];
            double probability = Double.parseDouble(parts[2]);

            graph.addDependency(
                    graph.getService(source),
                    graph.getService(target),
                    probability
            );
        }
//        System.out.println(
//                "Dependents of data_storage: " +
//                        graph.getDependents(graph.getService("data_storage")).size()
//        );
//        System.out.println(
//                "Dependents of data_storage: " +
//                        graph.getDependents(graph.getService("data_storage")).size()
//        );

        br.close();
    }

}