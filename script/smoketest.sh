for file in $(find "tests/termination/"); do
    echo "analysis of $file"
  ./main.exe $file -minimal -domain polyhedra
done
