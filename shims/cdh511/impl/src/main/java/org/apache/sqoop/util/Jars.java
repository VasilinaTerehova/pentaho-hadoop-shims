package org.apache.sqoop.util;

import com.cloudera.sqoop.manager.ConnManager;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.io.IOException;
import java.net.URL;
import java.net.URLDecoder;
import java.util.Enumeration;

/**
 * Created by Aliaksandr_Zhuk on 11/2/2017.
 */
public final class Jars {

    public static final Log LOG = LogFactory.getLog(
            Jars.class.getName());

    private Jars() {
    }

    /**
     * @return the path to the main Sqoop jar.
     */
    public static String getSqoopJarPath() {
        return getJarPathForClass(Jars.class);
    }

    /**
     * Return the jar file path that contains a particular class.
     * Method mostly cloned from o.a.h.mapred.JobConf.findContainingJar().
     */
    public static String getJarPathForClass(Class<? extends Object> classObj) {
        ClassLoader loader = classObj.getClassLoader();
        String s = "";

        //BundleContext b = FrameworkUtil.getBundle(Jars.class).getBundleContext();

        String classFile = classObj.getName().replaceAll("\\.", "/") + ".class";

       /* if(classFile.endsWith("JobConf.class")){

            classFile = "hadoop-mapreduce-client-core-2.6.0-cdh5.11.0.jar";
        }else{

            //classFile = "sqoop-1.4.6-cdh5.11.0.jar";
            classFile = "///D:/bundle.jar;///D:/sqoop-1.4.6-cdh5.11.0.jar";
            return classFile;
        }*/
        String toReturn = "";
        try {
            for (Enumeration<URL> itr = loader.getResources(classFile);
                 itr.hasMoreElements();) {
                URL url = (URL) itr.nextElement();
                if ("bundle".equals(url.getProtocol())) {
                    if(classFile.endsWith("JobConf.class")){
                        toReturn = "/D:/bundle.jar";

                    }else{
                        toReturn = "/D:/sqoop-1.4.6-cdh5.11.0.jar";
                    }


                    //String toReturn = "bundle://74.0:1/hadoop-hdfs-2.6.0-cdh5.11.0.jar;bundle://74.0:1/hadoop-common-2.6.0-cdh5.11.0.jar;bundle://74.0:1/sqoop-1.4.6-cdh5.11.0.jar";
                    if (toReturn.startsWith("file:")) {
                        toReturn = toReturn.substring("file:".length());
                        toReturn = toReturn.replaceAll("\\+", "%2B");
                        //toReturn = toReturn.replace("/", "\\");
                        toReturn = URLDecoder.decode(toReturn, "UTF-8");
                        return toReturn.replaceAll("!.*$", "");
                    }

                    return toReturn;

                }


                if ("jar".equals(url.getProtocol())) {
                     toReturn = url.getPath();
                    if (toReturn.startsWith("file:")) {
                        toReturn = toReturn.substring("file:".length());
                    }
                    // URLDecoder is a misnamed class, since it actually decodes
                    // x-www-form-urlencoded MIME type rather than actual
                    // URL encoding (which the file path has). Therefore it would
                    // decode +s to ' 's which is incorrect (spaces are actually
                    // either unencoded or encoded as "%20"). Replace +s first, so
                    // that they are kept sacred during the decoding process.
                    toReturn = toReturn.replaceAll("\\+", "%2B");
                    toReturn = URLDecoder.decode(toReturn, "UTF-8");
                    return toReturn.replaceAll("!.*$", "");
                }
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return null;
    }

    /**
     * Return the path to the jar containing the JDBC driver
     * for a ConnManager.
     */
    public static String getDriverClassJar(ConnManager mgr) {
        if (null == mgr) {
            return null;
        }

        String driverClassName = mgr.getDriverClass();
        if (null == driverClassName) {
            return null;
        }

        try {
            Class<? extends Object> driverClass = Class.forName(driverClassName);
            return getJarPathForClass(driverClass);
        } catch (ClassNotFoundException cnfe) {
            LOG.warn("No such class " + driverClassName + " available.");
            return null;
        }
    }

}
