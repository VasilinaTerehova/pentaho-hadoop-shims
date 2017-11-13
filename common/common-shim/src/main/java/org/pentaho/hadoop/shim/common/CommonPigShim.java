/*******************************************************************************
 * Pentaho Big Data
 * <p>
 * Copyright (C) 2002-2015 by Pentaho : http://www.pentaho.com
 * <p>
 * ******************************************************************************
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 ******************************************************************************/

package org.pentaho.hadoop.shim.common;

import com.google.common.collect.Multimaps;
import org.antlr.runtime.CommonTokenStream;
import org.apache.commons.io.FileUtils;
import org.apache.pig.ExecType;
import org.apache.pig.backend.hadoop.datastorage.ConfigurationUtil;
import org.apache.pig.backend.hadoop.executionengine.mapReduceLayer.PigMapReduce;
import org.apache.pig.impl.PigContext;
import org.apache.pig.impl.util.PropertiesUtil;
import org.apache.pig.tools.parameters.ParameterSubstitutionPreprocessor;
import org.apache.pig.tools.parameters.ParseException;
import org.apache.tools.bzip2r.BZip2Constants;
import org.codehaus.jackson.annotate.JsonPropertyOrder;
import org.codehaus.jackson.map.annotate.JacksonStdImpl;
import org.osgi.framework.BundleContext;
import org.pentaho.hadoop.shim.ShimVersion;
import org.pentaho.hadoop.shim.api.Configuration;
import org.pentaho.hadoop.shim.spi.PigShim;

import java.io.*;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;

public abstract class CommonPigShim implements PigShim {
  private static final String[] EMPTY_STRING_ARRAY = new String[ 0 ];


  private BundleContext bundleContext;

  public BundleContext getBundleContext() {
    return bundleContext;
  }

  public void setBundleContext( BundleContext bundleContext ) {
    this.bundleContext = bundleContext;
  }

  private enum ExternalPigJars {

    PIG( "pig" ),
    AUTOMATON( "automaton" ),
    ANTLR( "antlr-runtime" ),
    JACKSON_CORE( "jackson-core-asl" ),
    JACKSON_MAPPER( "jackson-mapper-asl" ),
    JODATIME( "joda-time" );

    private final String jarName;

    ExternalPigJars( String jarName ) {
      this.jarName = jarName;
    }

    public String getJarName() {
      return jarName;
    }

  }

  public void addExternalJarsToPigContext( PigContext pigContext ) throws MalformedURLException {
    for ( ExternalPigJars externalPigJars : ExternalPigJars.values() ) {
      String externaljarPath = "";
      externaljarPath = getExternalJarAbsolutePath( externalPigJars.getJarName() );
      pigContext.addJar( externaljarPath );
    }
  }

  private String getExternalJarAbsolutePath( String jarName ) {
    Iterator<File> filesIterator =
      FileUtils.iterateFiles( new File( new File( bundleContext.getBundle().getDataFile( "/" ).getParent() ).getParent()
          + File.separator ),
        new String[] { "jar" }, true );
    String jarPath = "";

    while ( filesIterator.hasNext() ) {
      File file = filesIterator.next();
      String name = file.getName();
      if ( name.startsWith( jarName ) ) {
        jarPath = file.getAbsolutePath();
        return jarPath;
      }
    }

    return jarPath;
  }

  @Override
  public ShimVersion getVersion() {
    return new ShimVersion( 1, 0 );
  }

  @Override
  public boolean isLocalExecutionSupported() {
    return true;
  }

  @Override
  public void configure( Properties properties, Configuration configuration ) {
    PropertiesUtil.loadDefaultProperties( properties );
    if ( configuration != null ) {
      properties.putAll( ConfigurationUtil.toProperties( ShimUtils.asConfiguration( configuration ) ) );
    }
  }

  @Override
  public String substituteParameters( URL pigScript, List<String> paramList ) throws IOException, ParseException {
    final InputStream inStream = pigScript.openStream();
    StringWriter writer = new StringWriter();
    // do parameter substitution
    ParameterSubstitutionPreprocessor psp = new ParameterSubstitutionPreprocessor( 50 );
    psp.genSubstitutedFile( new BufferedReader( new InputStreamReader( inStream ) ),
      writer,
      paramList.size() > 0 ? paramList.toArray( EMPTY_STRING_ARRAY ) : null, null );
    return writer.toString();
  }

  /**
   * Convert {@link ExecutionMode} to {@link ExecType}
   *
   * @param mode Execution mode
   * @return Type of execution for mode
   */
  protected ExecType getExecType( ExecutionMode mode ) {
    switch( mode ) {
      case LOCAL:
        return ExecType.LOCAL;
      case MAPREDUCE:
        return ExecType.MAPREDUCE;
      default:
        throw new IllegalStateException( "unknown execution mode: " + mode );
    }
  }

}
