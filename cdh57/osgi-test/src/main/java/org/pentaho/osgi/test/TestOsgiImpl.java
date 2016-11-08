package org.pentaho.osgi.test;

import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceEvent;
import org.osgi.framework.ServiceListener;
import org.osgi.framework.ServiceReference;
import org.pentaho.hadoop.shim.api.Configuration;
import org.pentaho.hadoop.shim.spi.HadoopShim;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Created by Vasilina_Terehova on 11/3/2016.
 */
public class TestOsgiImpl implements TestOsgi {
    private static final Logger logger = LoggerFactory.getLogger(TestOsgiImpl.class);
    private final BundleContext bundleContext;

    public TestOsgiImpl(final BundleContext bundleContext) {
        logger.error("service created");
        this.bundleContext = bundleContext;
        bundleContext.addServiceListener(new ServiceListener() {
            public void serviceChanged(ServiceEvent event) {
                //logger.error("version" + (bundleContext.getService(bundleContext.getBundle(281).getRegisteredServices()[0]).getClass().getInterfaces()));
                //try {
                ClassLoader oldTCCL = Thread.currentThread().getContextClassLoader();
                try {
                    //ClassLoader classLoader = bundleContext.getBundle(286).adapt(HadoopShim.class).getClass().getClassLoader();
                    //Thread.currentThread().setContextClassLoader(classLoader);
                    ClassLoader classLoader = getClass().getClassLoader();
                    //Thread.currentThread().setContextClassLoader(classLoader);
                    //logger.error("qqqq1 " + ((HadoopShim) bundleContext.getService(bundleContext.getBundle(286).getRegisteredServices()[0])).getHadoopVersion());
                    ServiceReference<HadoopShim> serviceReference = bundleContext.getServiceReference(HadoopShim.class);
                    if (serviceReference != null) {
                        HadoopShim hadoopShim = bundleContext.getService(serviceReference);
                        Configuration configuration = hadoopShim.createConfiguration();
                        configuration.set("fs.default.name", "hdfs://svqxbdcn6cdh57n1.pentahoqa.com:8020");
                        logger.error("qqqq1 " + hadoopShim.getHadoopVersion());

                    }
                } catch (Throwable e) {
                    System.out.println(e);
                } finally {
                    //Thread.currentThread().setContextClassLoader(oldTCCL);
                }
                //obj.getClass().getMethod("getHadoopVersion").invoke(obj, null);
//                } catch (IllegalAccessException e) {
//                    e.printStackTrace();
//                } catch (InvocationTargetException e) {
//                    e.printStackTrace();
//                } catch (NoSuchMethodException e) {
//                    e.printStackTrace();
//                };
                logger.error("service appeared class: " + bundleContext.getService(event.getServiceReference()));
                if (event.getServiceReference() instanceof HadoopShim) {
                    logger.error("shim received");
                    System.out.println("Hello we've found shim");
                }
            }
        });
    }

    public void echoTest() {
        System.out.println("hello test");
    }
}
