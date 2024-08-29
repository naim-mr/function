`Script`
==========

The `Script` directory contains the bash script to launch the benchmarks of the project.
You can manage the timeout of for each run in runtest.sh by changing the value of `$max_time` (default 5s).
In runscript.sh you can either choose `test_vuln` or `test` as directory for benchmarks.
The tests in `test_vuln` are adapted from ones in `test` for vulnerability analysis. We recommend using `test_vuln`.

The results are outputted in the directory `result`.


--------------
`HTML generation`

You can open them with the file `index.html`.  
You will see a table as follows:
| Filename | Option 1 | ... | Option n | Number of vulnerabilities|
|:-------:|:---------:|:---:|:--------:|:------------------------:|
| `filename.c` | `TRUE` | ... | `UNKNOW` | 1
                 {x,y}         {y,k}  
                 {x,z}         {k,v}

By clicking on each `TRUE` or `UNKNOW` you will be redirected to the logs of the analysis with the associated option for `filename.c`.

The variable in blue are potentially vulnerable and the ones in red a definitely safe.

--------------
`CSV generation and statistics`

A CSV file is also generated with data on the analysis. 
You can use it in a jupyter notebook the file `stats.ipynb`, already defined cells are proposed. Feel free to create your own statistics.

Already computed results are available in `computed_results/`.