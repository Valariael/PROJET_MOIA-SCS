default:
	javac -cp junit-4.13.jar:../out:".:/usr/lib/swi-prolog/lib/jpl.jar" TestQuantik.java -d ../out
	java -javaagent:jacocoagent.jar -cp junit-4.13.jar:hamcrest-core-1.3.jar:".:/usr/lib/swi-prolog/lib/jpl.jar":../out org.junit.runner.JUnitCore tests.TestQuantik
	java -jar jacococli.jar report jacoco.exec --classfiles ../out --sourcefiles ../src --html coverageReport