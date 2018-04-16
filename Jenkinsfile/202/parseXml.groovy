#!/usr/bin/env groovy


def pom = new XmlSlurper().parse(new File("pom.xml"))

println pom.version