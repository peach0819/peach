@echo off
"%JAVA_HOME%/bin/java" -classpath "%~dp0gradle/wrapper/gradle-wrapper.jar" org.gradle.wrapper.GradleWrapperMain %*
