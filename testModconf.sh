#! /bin/sh -
modconf="./modconf.sh";
conf="conf";
# Reset conf file
> $conf;
printf "Print usage on no arguments:\n";
sh $modconf
printf "Create test setting\n";
sh $modconf $conf "key" "value";
printf "Add comment with value\n";
sh $modonf -c ls;
printf "Appending value2.1 to test setting\n";
sh $modconf -a " value2.1" $conf "key";
printf "";
sh $modconf -r $conf "key" "value";

printf -- "--------\n";
cat $conf;
