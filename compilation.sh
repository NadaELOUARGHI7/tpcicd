javac -d bin/ -classpath lib/commons-lang3-3.5.jar src/fr/ubo/tetris/*.java
jar -cf Tetris.jar -C bin/ .
java -cp Tetris.jar:lib/commons-lang3-3.5.jar fr.ubo.tetris.Tetris
